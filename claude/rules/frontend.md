# Frontend Design

## Typography

| Property | Value | Why |
|----------|-------|-----|
| Body text | 16px minimum (1rem) | Below 16px causes readability issues and triggers iOS zoom on inputs |
| Line height | 1.5 for body, 1.2 for headings | Tighter headings look intentional, looser body aids scanning |
| Line length | 45-75 characters (max-w-prose or max-w-2xl) | Beyond 75 chars, the eye loses its place when returning to the next line |
| Heading scale | Use a consistent ratio (1.25x or 1.333x) | Arbitrary sizes look amateur. Tailwind's text-sm/base/lg/xl/2xl/3xl follows a ratio |
| Font weight | max 2-3 weights per page | More weights slow load and create visual noise |
| text-balance | Apply to headings (text-balance) | Prevents orphaned words on short final lines |
| text-pretty | Apply to body paragraphs (text-pretty) | Improves word spacing and prevents awkward breaks |

Prefer system font stacks or self-hosted fonts via `next/font`. Never load fonts from external CDNs: it adds a blocking request and leaks user data.

## Spacing

Use Tailwind's spacing scale consistently. Pick one vertical rhythm and stick with it.

- **Section padding**: py-20 sm:py-24 (80px/96px) for major sections
- **Between section title and content**: mt-12 (48px)
- **Between cards in a grid**: gap-6 (24px) or gap-8 (32px)
- **Inside cards**: p-6 (24px)
- **Between text elements**: mt-2 or mt-4, never arbitrary values

Never mix spacing scales. If cards use gap-6, all card grids use gap-6. Consistency is more important than any individual spacing choice.

## Color and Contrast

WCAG AA is the minimum. Not optional, not a stretch goal.

| Pair | Minimum ratio |
|------|--------------|
| Body text on background | 4.5:1 |
| Large text on background (>= 18px bold or >= 24px) | 3:1 |
| UI components and focus indicators | 3:1 against adjacent colors |
| Decorative elements | No requirement |

When defining a color system:

- Test every foreground/background pair that will actually appear together
- Muted text (secondary, captions, placeholders) is the most common failure point
- Primary/accent colors used as text almost always fail on light backgrounds. Darken them
- OKLCH lightness (L) is perceptually uniform. To increase contrast, decrease L for dark-on-light, increase L for light-on-dark
- Dark mode needs its own contrast check. Light mode passing does not guarantee dark mode passes

Use this Node.js snippet to verify OKLCH contrast ratios:

```javascript
// oklch-contrast.js — run with: node oklch-contrast.js
function oklchToOklab(L,C,H){const h=H*Math.PI/180;return{L,a:C*Math.cos(h),b:C*Math.sin(h)}}
function oklabToLinSrgb(L,a,b){const l=L+.3963377774*a+.2158037573*b,m=L-.1055613458*a-.0638541728*b,s=L-.0894841775*a-1.291485548*b;return{r:4.0767416621*l**3-3.3077115913*m**3+.2309699292*s**3,g:-1.2684380046*l**3+2.6097574011*m**3-.3413193965*s**3,b:-.0041960863*l**3-.7034186147*m**3+1.707614701*s**3}}
function linToSrgb(c){return c<=.0031308?12.92*c:1.055*c**(1/2.4)-.055}
function srgbToLin(c){return c<=.04045?c/12.92:((c+.055)/1.055)**2.4}
function relLum(r,g,b){return .2126*srgbToLin(Math.max(0,Math.min(1,r)))+.7152*srgbToLin(Math.max(0,Math.min(1,g)))+.0722*srgbToLin(Math.max(0,Math.min(1,b)))}
function oklchY(L,C,H){const lab=oklchToOklab(L,C,H),rgb=oklabToLinSrgb(lab.L,lab.a,lab.b);return relLum(linToSrgb(Math.max(0,rgb.r)),linToSrgb(Math.max(0,rgb.g)),linToSrgb(Math.max(0,rgb.b)))}
function cr(a,b){const x=Math.max(a,b),y=Math.min(a,b);return(x+.05)/(y+.05)}
// Usage: cr(oklchY(fgL,fgC,fgH), oklchY(bgL,bgC,bgH))
```

## Responsive Design

Mobile-first. Always. Write the mobile layout first, then add breakpoints for larger screens.

### Breakpoints

| Breakpoint | Tailwind | Use for |
|------------|----------|---------|
| Default | (none) | Mobile: single column, stacked layout |
| sm (640px) | sm: | Large phones in landscape, minor adjustments |
| md (768px) | md: | Tablets: 2-column grids, side-by-side layouts |
| lg (1024px) | lg: | Desktop: 3+ column grids, horizontal nav |
| xl (1280px) | xl: | Wide desktop: max-width containers, extra whitespace |

### Common patterns

- **Grids**: `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3` (never jump from 1 to 3)
- **Navigation**: mobile hamburger/sheet below md, horizontal nav at md+
- **Hero height**: use `100dvh` not `100vh` (dvh accounts for mobile browser chrome)
- **Container**: `max-w-6xl mx-auto px-4 sm:px-6 lg:px-8`
- **Images**: always set width and height attributes, use `next/image` for photos
- **Text scaling**: `text-3xl sm:text-4xl lg:text-5xl` for headings, not arbitrary values
- **Overflow**: use `overflow-x: clip` not `overflow-x: hidden` on html/body to avoid breaking sticky positioning

### Touch targets

Minimum 44x44px (2.75rem) for all interactive elements on mobile. This includes buttons, links, icon buttons, and form controls. Add padding to small elements: `min-h-[2.75rem] min-w-[2.75rem]`.

## Accessibility

### Semantic HTML

Use the right element, not a styled div.

| Need | Use | Not |
|------|-----|-----|
| Navigation links | `<nav>` with `<a>` | `<div>` with `onClick` |
| Page sections | `<section>` with aria-labelledby | `<div>` |
| Cards with actions | `<article>` or semantic `<div>` | `<a>` wrapping everything |
| Lists of items | `<ul>` / `<ol>` | `<div>` with manual bullets |
| Form fields | `<label>` with `htmlFor` | `<span>` above an input |

### ARIA guidelines

- Every `<section>` needs `aria-labelledby` pointing to its heading's `id`
- Navigation landmarks need `aria-label`: "Main", "Footer", "Mobile"
- Decorative elements get `aria-hidden="true"`
- Icon-only buttons need `aria-label`
- SVG icons inside text get `aria-hidden="true"` (the text provides context)
- Never use ARIA when a native HTML element does the job

### Focus management

- All interactive elements must have visible focus indicators
- Focus ring must have 3:1 contrast against adjacent colors
- Tab order must follow visual order (no positive tabindex values)
- Skip-to-content link as first focusable element on the page

### Motion

- Wrap all animations in `@media (prefers-reduced-motion: no-preference)`
- Provide CSS fallback with `prefers-reduced-motion: reduce` that shows content without animation
- Never animate opacity from 0 in a way that hides content from users who disable motion. Use opacity: 1 and transform: none as the reduced-motion state

## Component Patterns

### Cards

- Consistent padding (p-6)
- Hover state with subtle border color change (`hover:border-primary/30`), not shadow jumps
- If the card is clickable, the entire card should be the click target
- Card content order: icon/image, title, description, action

### Buttons

- Primary: filled background, high contrast text
- Secondary/outline: border, muted background on hover
- Full-width on mobile (`w-full sm:w-auto`), auto-width on desktop
- Loading state: disable button, show spinner + "Loading..." text
- Never rely on color alone to distinguish button variants (add text or icons)

### Forms

- Labels above inputs, not placeholder-only
- Error messages below the field, in destructive color
- Group related fields visually
- Submit button at the bottom, full-width on mobile
- Disable submit during pending state with visual feedback (spinner)
- All inputs need `name`, `id`, and matching `<label htmlFor>`

### Navigation

- Sticky header: `sticky top-0 z-50` with `backdrop-blur-lg` and semi-transparent background
- Scroll progress bar at the bottom of the header for long pages
- Mobile menu: use Sheet/drawer pattern, not a dropdown
- Active section highlighting with IntersectionObserver (optional, adds JS)
- Language/theme controls in the header bar, not buried in a menu

## Images and Icons

- Small icons (< 48px): inline SVG, never image files. This eliminates HTTP requests
- Large illustrations: SVG if vector, WebP/AVIF with next/image if raster
- Decorative backgrounds: CSS gradients and blurs (`bg-primary/5 blur-3xl`), not images
- Logo: inline SVG with `currentColor` for theme compatibility
- Always add `aria-hidden="true"` to decorative SVGs
- Icon components accept `className` prop for sizing: `h-5 w-5`

## Animation

- Prefer CSS transitions over JS animation libraries
- Use `transition-colors` for hover states, `transition-opacity` for reveals
- Scroll-triggered animations: IntersectionObserver + CSS classes, not scroll event listeners with JS animations
- Keep durations short: 150ms for micro-interactions, 300-600ms for reveals
- Use `ease-out` for enters, `ease-in` for exits
- Always respect `prefers-reduced-motion`

## Performance Checklist

| Check | How |
|-------|-----|
| No external font requests | Self-host via next/font or system stack |
| No external script tags | No analytics, chat widgets, or trackers in initial load |
| Images optimized | next/image with width/height, lazy loading by default |
| Client JS minimized | Server Components by default, "use client" only when needed |
| No layout shift | Set explicit dimensions on images, fonts, and dynamic content |
| CSS-only where possible | Prefer Tailwind utilities over runtime CSS-in-JS |
| Tree-shakeable imports | Import specific components, not entire libraries |

## Tailwind Conventions

- Use semantic color tokens (`bg-background`, `text-foreground`, `text-muted-foreground`) not raw colors
- Dark mode via CSS class strategy with `@custom-variant dark (&:is(.dark *))`
- Consistent radius: define `--radius` once, use `rounded-lg`, `rounded-md`, `rounded-sm`
- Consistent shadow scale: `shadow-sm` for subtle, `shadow-md` for cards, `shadow-lg` for modals
- Avoid `@apply` in CSS files. Write utilities in JSX. Exception: base styles in `@layer base`
- Group responsive variants left-to-right: `text-sm md:text-base lg:text-lg`

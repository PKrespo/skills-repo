# Dark Neon Graph UX — Reference

## Tailwind v4 Bridge

```css
/* src/styles/index.css */
@import "tailwindcss";
@import "./theme.css";

@theme inline {
  --color-bg: var(--bg);
  --color-surface: var(--surface);
  --color-surface-2: var(--surface-2);
  --color-border: var(--border);
  --color-success: var(--success);
  --color-danger: var(--danger);
  --color-warning: var(--warning);
  --color-info: var(--info);
  --color-text: var(--text);
  --color-text-dim: var(--text-dim);
  --color-text-faint: var(--text-faint);
  --font-sans: "Inter", system-ui, sans-serif;
}
```

## Base Body Styles

```css
* { box-sizing: border-box; }
html, body, #root { height: 100%; }
body {
  margin: 0;
  font-family: var(--font-sans);
  background: var(--bg);
  color: var(--text);
  -webkit-font-smoothing: antialiased;
}
```

## Scrollbar

```css
::-webkit-scrollbar { width: 6px; height: 6px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.12);
  border-radius: 3px;
}
```

## Surface Accent Classes (top wash)

Applied via `accent` prop on SurfaceCard. Uses `::before` pseudo at 72% height.

| Class | Top gradient |
|-------|-------------|
| `.surface-accent-success` | green 40% → 12% → transparent |
| `.surface-accent-danger` | red 40% → 12% → transparent |
| `.surface-accent-warning` | yellow 38% → 11% → transparent |
| `.surface-accent-info` | cyan 40% → 12% → transparent |
| `.surface-accent-neutral` | white 30% → 9% → transparent |

Each pairs with `border-t-2` and inline `borderTopColor: var(--{variant})`.

## Surface Glow Classes (corner glow)

Applied via `glow` prop. Dual pseudo-elements:
- `::before` — radial ellipse at top-right (55% × 55%)
- `::after` — diagonal linear gradient wash

| Class | Corner color |
|-------|-------------|
| `.surface-glow-success` | green radial + diagonal |
| `.surface-glow-danger` | red radial + diagonal |
| `.surface-glow-warning` | yellow radial + diagonal |
| `.surface-glow-info` | cyan radial + diagonal |
| `.surface-glow-neutral` | white radial + diagonal |

## Chart Glow Filters

```css
.chart-glow-green {
  filter: drop-shadow(0 0 1.5px rgba(0, 230, 118, 0.95))
    drop-shadow(0 0 5px rgba(0, 230, 118, 0.6))
    drop-shadow(0 0 11px rgba(0, 230, 118, 0.35));
}
.chart-glow-cyan {
  filter: drop-shadow(0 0 1.5px rgba(0, 176, 255, 0.95))
    drop-shadow(0 0 5px rgba(0, 176, 255, 0.6))
    drop-shadow(0 0 11px rgba(0, 176, 255, 0.35));
}
.chart-glow-red {
  filter: drop-shadow(0 0 1.5px rgba(255, 23, 68, 0.9))
    drop-shadow(0 0 5px rgba(255, 23, 68, 0.55))
    drop-shadow(0 0 11px rgba(255, 23, 68, 0.3));
}
```

## GlowVariant Type

```ts
export type GlowVariant =
  | "success"
  | "danger"
  | "warning"
  | "info"
  | "neutral"
  | "none";
```

## surfaceGlow.ts

```ts
const glowClasses: Record<GlowVariant, string> = {
  success: "surface-glow-success",
  danger: "surface-glow-danger",
  warning: "surface-glow-warning",
  info: "surface-glow-info",
  neutral: "surface-glow-neutral",
  none: "",
};
```

## Button Variants

| Variant | Classes |
|---------|---------|
| primary | `bg-info/20 text-info border-info/40 hover:bg-info/30` |
| ghost | `text-text-dim hover:bg-white/5 hover:text-text` |
| outline | `border-border text-text-dim hover:bg-white/5` |

## Spacing Rhythm

| Context | Value |
|---------|-------|
| Page padding | `p-6` |
| Section gap | `gap-4` / `space-y-4` |
| Chart sub-grid | `gap-3` |
| List items | `gap-2` |
| Card padding | `p-4` (md) / `p-3` (sm) |
| Sidebar width | `w-60` / `w-16` collapsed |

## chartMeta Convention

Keep threshold constants separate from generated data:

```ts
export const chartMeta = {
  pointCount: 53,
  anomalyCount: 3,
  reliabilitySla: 99,
  latencyBudget: 300,
  errorBudget: 1,
};
```

## Filter Header Sub-surface

```tsx
<div className="rounded-lg border border-border bg-surface-2/50 p-3">
  {/* env select, time range, search, toggles */}
</div>
```

## Live Badge

```tsx
<span className="inline-flex items-center gap-1.5 rounded-full border border-success/30 bg-success/10 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-success">
  <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-success" />
  Live
</span>
```

## Progress Bar (KPI)

```tsx
<div className="mt-3 h-1 w-full overflow-hidden rounded-full bg-white/5">
  <div
    className="h-full rounded-full transition-all"
    style={{
      width: `${progress}%`,
      backgroundColor: progressColor,
      boxShadow: `0 0 8px ${progressColor}66`,
    }}
  />
</div>
```

## List Panel Item

```tsx
<div className="rounded-lg border border-border bg-surface-2 p-3">
  <div className="flex items-start justify-between gap-2">
    <div>…title + target…</div>
    <Badge variant="danger">P1</Badge>
  </div>
</div>
```

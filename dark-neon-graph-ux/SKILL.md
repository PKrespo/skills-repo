---
name: dark-neon-graph-ux
description: >-
  Builds dark neon observability dashboards and chart/graph UIs with the
  Mission Control visual system — semantic glow surfaces, Recharts dark theme,
  SVG radial gauges, and collapsible app shell. Use when creating dashboards,
  time-series charts, metric graphs, data visualization apps, or any UI that
  should match the lumina-abundia-graph look and feel across projects.
---

# Dark Neon Graph UX

Reusable visual UX pattern extracted from `lumina-abundia-graph`. Apply this skill whenever building dashboards, charts, or graph-style data views that should share the same **Mission Control dark neon** aesthetic.

## Visual Identity

| Principle | Rule |
|-----------|------|
| Mood | Internal NOC / observability command center |
| Background | Near-black `#0b0e14`, layered glass surfaces |
| Accents | Neon semantic colors with glow (not flat Material) |
| Hierarchy | KPI row → status row → gauge + charts → detail panels |
| Density | Compact micro-labels, generous card padding, no clutter |
| Motion | Subtle — gauge ring reveal, live pulse dot, hover states only |

## Tech Stack (default)

| Layer | Choice |
|-------|--------|
| Framework | React + TypeScript |
| Build | Vite |
| Styling | Tailwind CSS v4 (`@tailwindcss/vite`) |
| Charts | Recharts (time-series) |
| Custom viz | Hand-rolled SVG (gauges, future topology) |
| Icons | Lucide React |

Adapt stack only when the target project already uses something else — **preserve the visual tokens and component patterns**.

## Setup Checklist

When bootstrapping or theming a new project:

```
- [ ] Copy design tokens → src/styles/theme.css
- [ ] Copy glow utilities → src/styles/index.css (see reference.md)
- [ ] Bridge tokens to Tailwind via @theme inline
- [ ] Add Inter font (400–700) in index.html
- [ ] Define GlowVariant type (success | danger | warning | info | neutral | none)
- [ ] Create SurfaceCard + Badge primitives
- [ ] Create chart wrapper (ChartCard) with shared Recharts config
- [ ] Wire AppShell (sidebar + topbar + scrollable main)
```

## Design Tokens

Always use CSS variables — never hardcode hex in components.

```css
/* src/styles/theme.css */
:root {
  --bg: #0b0e14;
  --surface: #12161f;
  --surface-2: #1a1f2e;
  --border: rgba(255, 255, 255, 0.08);
  --success: #00e676;
  --danger: #ff1744;
  --warning: #ffd600;
  --info: #00b0ff;
  --text: #f1f5f9;
  --text-dim: #94a3b8;
  --text-faint: #64748b;
  --surface-radius: 0.75rem;
}
```

Full token bridge, glow CSS, and scrollbar styles: [reference.md](reference.md).

## GlowVariant — Semantic Color System

One type drives all accent semantics across cards, badges, charts, and (future) graph nodes.

| Variant | Use for |
|---------|---------|
| `success` | Healthy, SLA met, uptime |
| `danger` | Errors, breaches, firing incidents |
| `warning` | Budget warnings, availability risk |
| `info` | Latency, interactive, neutral metrics |
| `neutral` | Default / non-semantic |
| `none` | No accent |

Map metric types to variants consistently:

| Metric | Color | Chart glow class |
|--------|-------|------------------|
| Reliability | `--success` | `chart-glow-green` |
| Latency | `--info` | `chart-glow-cyan` |
| Errors | `--danger` | `chart-glow-red` |
| Availability | `--warning` | — |

## SurfaceCard — Core Container

Two accent modes — pick one per card type:

| Mode | Prop | Visual | Use on |
|------|------|--------|--------|
| Top wash | `accent` | Top border + downward gradient | KPI cards |
| Corner glow | `glow` | Radial corner + diagonal wash | Status, charts, panels |

```tsx
// KPI: top accent wash
<SurfaceCard glow="none" accent="success">…</SurfaceCard>

// Chart/status: corner glow
<SurfaceCard glow="info">…</SurfaceCard>
```

Always wrap children in `relative z-10` inside SurfaceCard so content sits above pseudo-element effects.

Base classes: `rounded-xl border border-border bg-surface/80 backdrop-blur-sm p-4`.

## Component Hierarchy

```
AppShell
├── Sidebar (collapsible w-60 ↔ w-16, mobile overlay)
├── TopBar (env badge, search, clock, actions)
└── Page
    ├── DashboardHeader (title, live badge, filter bar)
    └── Content grid
        ├── KpiCard × 4          (accent mode)
        ├── StatusCard × 4       (glow mode)
        ├── [Gauge | ChartGrid]  (gauge narrow, charts wide)
        └── Panel × 2            (list detail)
```

## Dashboard Grid Template

```tsx
<div className="space-y-4 p-6">
  {/* Row 1 — KPIs */}
  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">…</div>

  {/* Row 2 — Status */}
  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">…</div>

  {/* Row 3 — Gauge + Charts */}
  <div className="grid grid-cols-1 gap-4 xl:grid-cols-[minmax(190px,0.9fr)_minmax(0,4.5fr)]">
    <SurfaceCard>…gauge…</SurfaceCard>
    <ReliabilitySignalsSection>…3 charts…</ReliabilitySignalsSection>
  </div>

  {/* Row 4 — Detail panels */}
  <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">…</div>
</div>
```

## Recharts Dark Theme Recipe

Every time-series chart must follow this config:

- `ResponsiveContainer width="100%" height={220}`
- Grid: `stroke="rgba(255,255,255,0.06)" strokeDasharray="3 3"`
- Axes: no tick/axis lines, `fontSize: 10`, `fill: var(--text-faint)`
- XAxis: `interval="preserveStartEnd"`
- Tooltip: custom dark div (`bg-surface border-border text-xs shadow-xl`)
- Area fill: `linearGradient` 18% → 2% opacity of semantic color
- Stroke: `className="chart-glow-{green|cyan|red}"` for neon glow
- Thresholds: `ReferenceLine` (dashed) + `ReferenceArea` from `chartMeta`
- Anomalies: custom dot renderer with `var(--danger)` fill

Wrap each chart in `ChartCard` (title + badges header).

## SVG Radial Gauge Pattern

For composite health / multi-metric gauges:

- `viewBox="0 0 240 200"`, center `(120, 120)`
- 270° arc sweep starting at 135° (gap at bottom-left)
- Concentric rings with decreasing radii (e.g. 95, 75, 55)
- Reveal animation: `strokeDashoffset` transition 1s ease-out on mount
- Per-ring `drop-shadow` glow on stroke
- Legend below: color dot + label + value (`text-xs text-text-dim`)

Reusable arc helpers: `polarToCartesian()`, `describeArc()` — see [examples.md](examples.md).

## Typography Scale

| Role | Classes |
|------|---------|
| Micro label | `text-[10px] font-semibold uppercase tracking-widest text-text-faint` |
| Badge | `text-[10px] font-semibold uppercase tracking-wider` |
| KPI value | `text-3xl font-bold tracking-tight text-text` |
| Status value | `text-2xl font-bold` |
| Section title | `text-sm font-semibold text-text` |
| Page title | `text-2xl font-bold` |
| Subtext | `text-xs text-text-dim` |

## Badge Pattern

Pill badges with semantic tint:

```
bg-{variant}/15 text-{variant} border-{variant}/30
rounded-full border px-2 py-0.5
```

Use badges in chart headers for SLA %, point counts, budgets — not separate legend components.

## App Shell Pattern

- Flex row: sidebar + main column, `h-full overflow-hidden`
- Sidebar: `w-60` expanded / `w-16` collapsed; fixed overlay on mobile with backdrop
- Main: `flex-1 overflow-y-auto` scrollable content
- Nav: data-driven `navConfig.ts` with `enabled` flag for coming-soon pages
- TopBar: `bg-surface/60 backdrop-blur-md`, live clock, env badge, search (`font-mono text-xs`)

## Data Layer Convention

```
src/types/     → shared interfaces (GlowVariant, TimePoint, filters)
src/data/      → static/mock exports
```

- Time-series: `{ time, value, anomaly? }[]`
- Thresholds in `chartMeta` separate from data
- Page-level filter state; filters that actually slice displayed data

## Extending to Node-Edge Graphs

When adding topology graphs (React Flow, Cytoscape, etc.):

| Graph element | Map to |
|---------------|--------|
| Node health | `GlowVariant` → node border/stroke color |
| Node container | `SurfaceCard` styling on node component |
| Edge status | Semantic color + `chart-glow-*` drop-shadow |
| Canvas background | `var(--bg)` |
| Selected/hover | `var(--info)` accent |
| Critical node | `accent="danger"` top-wash or red glow |

Keep graph canvas inside the dashboard grid — gauge-left, graph-right, or full-width panel.

## File Structure (new project)

```
src/
├── styles/
│   ├── theme.css          # tokens
│   └── index.css          # Tailwind + glow utilities
├── types/
│   └── observability.ts   # GlowVariant, data interfaces
├── layout/
│   ├── AppShell.tsx
│   ├── Sidebar.tsx
│   ├── TopBar.tsx
│   └── navConfig.ts
├── components/
│   ├── ui/
│   │   ├── SurfaceCard.tsx
│   │   ├── surfaceGlow.ts
│   │   ├── Badge.tsx
│   │   ├── Button.tsx
│   │   ├── KpiCard.tsx
│   │   └── StatusCard.tsx
│   ├── charts/
│   │   ├── ChartCard.tsx
│   │   ├── *Chart.tsx
│   │   └── MissionControlGauge.tsx
│   ├── panels/
│   └── filters/
│       └── DashboardHeader.tsx
├── pages/
└── data/
```

## Do / Don't

| Do | Don't |
|----|-------|
| CSS variables for all colors | Hex literals in JSX |
| `GlowVariant` for semantics | Ad-hoc color strings per component |
| Fixed chart height 220px | Variable chart heights in a row |
| Custom dark tooltip | Recharts default white tooltip |
| `backdrop-blur-sm` on surfaces | Opaque flat cards |
| Uppercase micro-labels | Sentence-case tiny labels |
| `relative z-10` on card content | Content behind glow pseudo-elements |

## Reference

- Full CSS utilities and Tailwind bridge: [reference.md](reference.md)
- Component templates and arc math: [examples.md](examples.md)
- Source reference implementation: `lumina-abundia-graph` repo

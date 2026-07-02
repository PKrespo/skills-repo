# Dark Neon Graph UX — Examples

## SurfaceCard

```tsx
import type { GlowVariant } from "@/types/observability";

const glowClasses: Record<GlowVariant, string> = {
  success: "surface-glow-success",
  danger: "surface-glow-danger",
  warning: "surface-glow-warning",
  info: "surface-glow-info",
  neutral: "surface-glow-neutral",
  none: "",
};

const accentClasses: Record<GlowVariant, string> = {
  success: "surface-accent-success border-t-2",
  danger: "surface-accent-danger border-t-2",
  warning: "surface-accent-warning border-t-2",
  info: "surface-accent-info border-t-2",
  neutral: "surface-accent-neutral border-t-2",
  none: "",
};

export function SurfaceCard({ children, glow = "none", accent = "none", padding = "md" }) {
  const paddingClass = padding === "sm" ? "p-3" : "p-4";
  const borderTopColor =
    accent !== "none" ? `var(--${accent === "neutral" ? "text-faint" : accent})` : undefined;

  return (
    <div
      className={`rounded-xl border border-border bg-surface/80 backdrop-blur-sm ${paddingClass} ${glowClasses[glow]} ${accentClasses[accent]}`}
      style={borderTopColor ? { borderTopColor } : undefined}
    >
      <div className="relative z-10">{children}</div>
    </div>
  );
}
```

## KpiCard

```tsx
export function KpiCard({ label, value, subtext, glow = "none", progress, progressColor = "var(--success)" }) {
  const accent = glow === "none" ? "neutral" : glow;
  return (
    <SurfaceCard glow="none" accent={accent} className="flex flex-col">
      <span className="text-[10px] font-semibold uppercase tracking-widest text-text-faint">{label}</span>
      <div className="mt-2 text-3xl font-bold tracking-tight text-text">{value}</div>
      {subtext && <div className="mt-1 text-xs text-text-dim">{subtext}</div>}
      {progress !== undefined && (
        <div className="mt-3 h-1 w-full overflow-hidden rounded-full bg-white/5">
          <div
            className="h-full rounded-full transition-all"
            style={{ width: `${progress}%`, backgroundColor: progressColor, boxShadow: `0 0 8px ${progressColor}66` }}
          />
        </div>
      )}
    </SurfaceCard>
  );
}
```

## Recharts Area Chart

```tsx
function DarkTooltip({ active, payload, label, valueSuffix = "%", color = "var(--success)" }) {
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded-lg border border-border bg-surface px-3 py-2 text-xs shadow-xl">
      <div className="text-text-faint">{label}</div>
      <div className="font-semibold" style={{ color }}>{payload[0].value}{valueSuffix}</div>
    </div>
  );
}

function AnomalyDot({ cx, cy, payload }) {
  if (!payload?.anomaly || cx === undefined || cy === undefined) return null;
  return <circle cx={cx} cy={cy} r={4} fill="var(--danger)" stroke="var(--text)" strokeWidth={1.5} />;
}

export function MetricChart({ data, color = "var(--success)", glowClass = "chart-glow-green", sla }) {
  return (
    <ResponsiveContainer width="100%" height={220}>
      <AreaChart data={data} margin={{ top: 8, right: 8, left: -20, bottom: 0 }}>
        <defs>
          <linearGradient id="areaGrad" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={color} stopOpacity={0.18} />
            <stop offset="100%" stopColor={color} stopOpacity={0.02} />
          </linearGradient>
        </defs>
        <CartesianGrid stroke="rgba(255,255,255,0.06)" strokeDasharray="3 3" />
        <XAxis dataKey="time" tick={{ fill: "var(--text-faint)", fontSize: 10 }} tickLine={false} axisLine={false} interval="preserveStartEnd" />
        <YAxis tick={{ fill: "var(--text-faint)", fontSize: 10 }} tickLine={false} axisLine={false} />
        <Tooltip content={<DarkTooltip color={color} />} />
        {sla && <ReferenceLine y={sla} stroke={color} strokeDasharray="4 4" strokeOpacity={0.6} />}
        <Area
          type="monotone"
          dataKey="value"
          stroke={color}
          strokeWidth={2.5}
          fill="url(#areaGrad)"
          className={glowClass}
          dot={<AnomalyDot />}
          activeDot={{ r: 5, fill: color }}
        />
      </AreaChart>
    </ResponsiveContainer>
  );
}
```

## SVG Arc Utilities

```ts
function polarToCartesian(cx: number, cy: number, r: number, angleDeg: number) {
  const angleRad = ((angleDeg - 90) * Math.PI) / 180;
  return { x: cx + r * Math.cos(angleRad), y: cy + r * Math.sin(angleRad) };
}

function describeArc(cx: number, cy: number, r: number, startAngle: number, endAngle: number) {
  const start = polarToCartesian(cx, cy, r, endAngle);
  const end = polarToCartesian(cx, cy, r, startAngle);
  const largeArc = endAngle - startAngle <= 180 ? 0 : 1;
  return `M ${start.x} ${start.y} A ${r} ${r} 0 ${largeArc} 0 ${end.x} ${end.y}`;
}
```

## Gauge Ring

```tsx
function Ring({ cx, cy, radius, value, color, trackColor, strokeWidth, animated }) {
  const startAngle = 135;
  const totalAngle = 270;
  const sweep = (value / 100) * totalAngle;
  const trackPath = describeArc(cx, cy, radius, startAngle, startAngle + totalAngle);
  const valuePath = sweep > 0 ? describeArc(cx, cy, radius, startAngle, startAngle + sweep) : "";
  const circumference = 2 * Math.PI * radius * (totalAngle / 360);

  return (
    <g>
      <path d={trackPath} fill="none" stroke={trackColor} strokeWidth={strokeWidth} strokeLinecap="round" />
      {valuePath && (
        <path
          d={valuePath}
          fill="none"
          stroke={color}
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={animated ? 0 : circumference}
          style={{ transition: "stroke-dashoffset 1s ease-out", filter: `drop-shadow(0 0 4px ${color}88)` }}
        />
      )}
    </g>
  );
}
```

## Dashboard Page Skeleton

```tsx
export function DashboardPage() {
  const [filters, setFilters] = useState(defaultFilters);

  return (
    <div>
      <DashboardHeader filters={filters} onFiltersChange={setFilters} onReset={() => setFilters(defaultFilters)} />
      <div className="space-y-4 p-6">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <KpiCard label="Metric A" value="99.2%" glow="success" />
          {/* …3 more KPIs */}
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <StatusCard label="Systems" value="94%" icon={Shield} iconColor="var(--success)" />
          {/* …3 more status cards */}
        </div>
        <div className="grid grid-cols-1 gap-4 xl:grid-cols-[minmax(190px,0.9fr)_minmax(0,4.5fr)]">
          <SurfaceCard><MissionControlGauge … /></SurfaceCard>
          <SurfaceCard>
            <div className="grid grid-cols-1 gap-3 md:grid-cols-3">
              <ChartCard title="SLA" glow="success"><MetricChart … /></ChartCard>
              <ChartCard title="Latency" glow="info"><MetricChart color="var(--info)" glowClass="chart-glow-cyan" … /></ChartCard>
              <ChartCard title="Errors" glow="danger"><MetricChart color="var(--danger)" glowClass="chart-glow-red" … /></ChartCard>
            </div>
          </SurfaceCard>
        </div>
        <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
          <DetailPanel title="Active issues" items={…} />
          <DetailPanel title="Top offenders" items={…} />
        </div>
      </div>
    </div>
  );
}
```

## Node-Edge Graph Extension (React Flow)

When adding topology graphs, style nodes to match the system:

```tsx
const nodeStyles: Record<GlowVariant, React.CSSProperties> = {
  success: { borderColor: "var(--success)", boxShadow: "0 0 12px rgba(0,230,118,0.3)" },
  danger:  { borderColor: "var(--danger)",  boxShadow: "0 0 12px rgba(255,23,68,0.3)" },
  warning: { borderColor: "var(--warning)", boxShadow: "0 0 12px rgba(255,214,0,0.25)" },
  info:    { borderColor: "var(--info)",    boxShadow: "0 0 12px rgba(0,176,255,0.3)" },
  neutral: { borderColor: "var(--border)" },
  none:    { borderColor: "var(--border)" },
};

function GraphNode({ data }) {
  return (
    <div
      className="rounded-xl border bg-surface/90 px-3 py-2 backdrop-blur-sm"
      style={nodeStyles[data.health]}
    >
      <div className="text-[10px] font-semibold uppercase tracking-widest text-text-faint">{data.type}</div>
      <div className="text-sm font-semibold text-text">{data.label}</div>
    </div>
  );
}
```

Canvas: `background: var(--bg)`. Edges: stroke `var(--text-faint)` default, `var(--danger)` on error paths with `chart-glow-red` filter.

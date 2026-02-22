"use client"

import { useMemo, useState } from "react"
import { LineChart, ShieldCheck, Target } from "lucide-react"
import { useScrollReveal } from "@/hooks/use-scroll-reveal"

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max)
}

export function StartupFeatures() {
  const { ref, visible } = useScrollReveal(0.08)
  const [carbShiftHours, setCarbShiftHours] = useState(0)
  const [walkMinutes, setWalkMinutes] = useState(0)
  const [urgency, setUrgency] = useState("Curious / exploring")
  const [goal, setGoal] = useState("Fewer spikes")

  const targetScoreGain = useMemo(() => {
    return carbShiftHours * 1.8 + (walkMinutes / 10) * 1.6
  }, [carbShiftHours, walkMinutes])

  const confidenceSpread = useMemo(() => {
    const center = 72 + targetScoreGain
    const width = clamp(16 - targetScoreGain * 0.9, 8, 16)
    return {
      min: Math.round(clamp(center - width / 2, 48, 96)),
      mean: Math.round(clamp(center, 50, 98)),
      max: Math.round(clamp(center + width / 2, 52, 99)),
    }
  }, [targetScoreGain])

  const timeline = useMemo(() => {
    const breakfastPeak = clamp(145 - carbShiftHours * 7, 112, 145)
    const dinnerPeak = clamp(168 - (walkMinutes / 5) * 3, 126, 168)
    return { breakfastPeak, dinnerPeak }
  }, [carbShiftHours, walkMinutes])

  return (
    <section className="relative px-6 py-28 lg:py-36">
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-border to-transparent" />
        <div className="absolute left-1/2 top-1/2 h-[640px] w-[640px] -translate-x-1/2 -translate-y-1/2 rounded-full bg-primary/[0.03] blur-[140px]" />
      </div>

      <div ref={ref} className="mx-auto max-w-screen-xl">
        <div className="grid gap-5 lg:grid-cols-3">
          <div
            className={`card-premium gradient-border rounded-3xl bg-card/45 p-7 transition-all duration-700 ease-out ${
              visible ? "translate-y-0 opacity-100" : "translate-y-8 opacity-0"
            }`}
            style={{ transitionDelay: "120ms" }}
          >
            <div className="flex items-center gap-2 text-primary/80">
              <LineChart className="h-4 w-4" strokeWidth={1.6} />
              <p className="text-[12px] uppercase tracking-[0.22em]">What-if Timeline</p>
            </div>
            <div className="mt-5 space-y-4">
              <label className="block">
                <div className="mb-1.5 flex items-center justify-between text-[12px]">
                  <span>Shift carbs earlier</span>
                  <span className="tabular-nums text-primary">{carbShiftHours.toFixed(1)}h</span>
                </div>
                <input
                  type="range"
                  min={0}
                  max={3}
                  step={0.5}
                  value={carbShiftHours}
                  onChange={(e) => setCarbShiftHours(parseFloat(e.target.value))}
                  className="w-full cursor-pointer appearance-none bg-transparent [&::-webkit-slider-runnable-track]:h-1 [&::-webkit-slider-runnable-track]:rounded-full [&::-webkit-slider-runnable-track]:bg-border [&::-webkit-slider-thumb]:mt-[-5px] [&::-webkit-slider-thumb]:h-3 [&::-webkit-slider-thumb]:w-3 [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-primary"
                />
              </label>
              <label className="block">
                <div className="mb-1.5 flex items-center justify-between text-[12px]">
                  <span>Post-dinner walk</span>
                  <span className="tabular-nums text-primary">{walkMinutes} min</span>
                </div>
                <input
                  type="range"
                  min={0}
                  max={30}
                  step={5}
                  value={walkMinutes}
                  onChange={(e) => setWalkMinutes(parseInt(e.target.value, 10))}
                  className="w-full cursor-pointer appearance-none bg-transparent [&::-webkit-slider-runnable-track]:h-1 [&::-webkit-slider-runnable-track]:rounded-full [&::-webkit-slider-runnable-track]:bg-border [&::-webkit-slider-thumb]:mt-[-5px] [&::-webkit-slider-thumb]:h-3 [&::-webkit-slider-thumb]:w-3 [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-primary"
                />
              </label>
            </div>
            <div className="mt-5 space-y-2">
              <div className="flex items-center justify-between text-[12px]">
                <span>Breakfast peak</span>
                <span className="tabular-nums">{timeline.breakfastPeak} mg/dL</span>
              </div>
              <div className="h-1.5 rounded-full bg-border">
                <div
                  className="h-1.5 rounded-full bg-primary/70 transition-all duration-300"
                  style={{ width: `${(timeline.breakfastPeak / 180) * 100}%` }}
                />
              </div>
              <div className="flex items-center justify-between text-[12px]">
                <span>Dinner peak</span>
                <span className="tabular-nums">{timeline.dinnerPeak} mg/dL</span>
              </div>
              <div className="h-1.5 rounded-full bg-border">
                <div
                  className="h-1.5 rounded-full bg-primary/70 transition-all duration-300"
                  style={{ width: `${(timeline.dinnerPeak / 180) * 100}%` }}
                />
              </div>
            </div>
          </div>

          <div
            className={`card-premium gradient-border rounded-3xl bg-card/45 p-7 transition-all duration-700 ease-out ${
              visible ? "translate-y-0 opacity-100" : "translate-y-8 opacity-0"
            }`}
            style={{ transitionDelay: "190ms" }}
          >
            <div className="flex items-center gap-2 text-primary/80">
              <ShieldCheck className="h-4 w-4" strokeWidth={1.6} />
              <p className="text-[12px] uppercase tracking-[0.22em]">Confidence Band</p>
            </div>
            <div className="mt-7 rounded-2xl border border-border/70 bg-background/60 p-5">
              <div className="flex items-end justify-between">
                <p className="text-[12px] uppercase tracking-[0.16em] text-muted-foreground">Projected score</p>
                <p className="font-serif text-[30px] leading-none text-foreground">{confidenceSpread.mean}</p>
              </div>
              <div className="mt-4 h-2 rounded-full bg-border">
                <div
                  className="h-2 rounded-full bg-gradient-to-r from-primary/25 via-primary/60 to-primary/25 transition-all duration-300"
                  style={{
                    marginLeft: `${confidenceSpread.min}%`,
                    width: `${Math.max(confidenceSpread.max - confidenceSpread.min, 5)}%`,
                  }}
                />
              </div>
              <div className="mt-2 flex items-center justify-between text-[12px] tabular-nums text-muted-foreground">
                <span>{confidenceSpread.min}</span>
                <span>{confidenceSpread.max}</span>
              </div>
            </div>
          </div>

          <div
            className={`card-premium gradient-border rounded-3xl bg-card/45 p-7 transition-all duration-700 ease-out ${
              visible ? "translate-y-0 opacity-100" : "translate-y-8 opacity-0"
            }`}
            style={{ transitionDelay: "260ms" }}
          >
            <div className="flex items-center gap-2 text-primary/80">
              <Target className="h-4 w-4" strokeWidth={1.6} />
              <p className="text-[12px] uppercase tracking-[0.22em]">Waitlist Qualifier</p>
            </div>
            <div className="mt-5 space-y-3">
              <label className="block text-[12px] text-muted-foreground">
                Urgency
                <select
                  value={urgency}
                  onChange={(e) => setUrgency(e.target.value)}
                  className="mt-1.5 w-full rounded-xl border border-border bg-background/60 px-3 py-2 text-[13px] text-foreground outline-none transition-colors focus:border-primary/40"
                >
                  <option>Curious / exploring</option>
                  <option>Need better control now</option>
                  <option>Clinician referred</option>
                </select>
              </label>
              <label className="block text-[12px] text-muted-foreground">
                Primary goal
                <select
                  value={goal}
                  onChange={(e) => setGoal(e.target.value)}
                  className="mt-1.5 w-full rounded-xl border border-border bg-background/60 px-3 py-2 text-[13px] text-foreground outline-none transition-colors focus:border-primary/40"
                >
                  <option>Fewer spikes</option>
                  <option>Steadier overnight trend</option>
                  <option>Energy/performance consistency</option>
                </select>
              </label>
            </div>
            <div className="mt-5 rounded-2xl border border-border/70 bg-background/60 p-4 text-[12px]">
              <p className="text-foreground">
                {urgency === "Need better control now" || urgency === "Clinician referred"
                  ? "Prioritize founder or clinical onboarding call."
                  : "Route to self-serve waitlist flow."}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

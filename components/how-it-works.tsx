"use client"

import { Link2, Activity, Compass, TrendingUp } from "lucide-react"
import { useScrollReveal } from "@/hooks/use-scroll-reveal"

const steps = [
  {
    number: "01",
    icon: Link2,
    title: "Sync your data",
    description:
      "Connect your CGM and log simple lifestyle inputs -- sleep, meals, activity, stress. Everything Verazoi needs to start building your profile.",
  },
  {
    number: "02",
    icon: Activity,
    title: "Receive your Stability Score",
    description:
      "Your Stability Score is calculated by combining CGM glucose variability, trend consistency, lifestyle behavior patterns, and behavioral impact correlations.",
  },
  {
    number: "03",
    icon: Compass,
    title: "Explore personalized options",
    description:
      "Verazoi analyzes your patterns and presents 3-4 personalized recommendations. Add a 12-minute walk after dinner. Shift carbohydrate timing earlier.",
  },
  {
    number: "04",
    icon: TrendingUp,
    title: "See projected impact",
    description:
      "Each recommendation shows an estimated improvement in your Stability Score before you implement it. You choose what fits your life.",
  },
]

export function HowItWorks() {
  const { ref, visible } = useScrollReveal(0.1)

  return (
    <section id="how-it-works" className="relative px-6 py-28 lg:py-36">
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-border to-transparent" />
        <div className="absolute right-0 top-1/2 h-[500px] w-[500px] -translate-y-1/2 rounded-full bg-primary/[0.02] blur-[120px]" />
      </div>

      <div ref={ref} className="mx-auto max-w-screen-lg">
        <div
          className={`text-center transition-all duration-700 ease-out ${
            visible ? "translate-y-0 opacity-100" : "translate-y-10 opacity-0"
          }`}
        >
          <p className="text-[12px] font-medium uppercase tracking-[0.3em] text-primary/60">
            How It Works
          </p>
          <h2 className="mx-auto mt-6 max-w-xl font-serif text-[clamp(1.75rem,3.5vw,3rem)] font-light leading-[1.1] text-foreground text-balance">
            Four steps to structured clarity
          </h2>
        </div>

        <div className="mt-20 grid gap-5 md:grid-cols-2">
          {steps.map((step, i) => (
            <div
              key={step.number}
              className={`card-premium gradient-border rounded-2xl bg-card/40 p-8 transition-all duration-700 ease-out ${
                visible
                  ? "translate-y-0 opacity-100"
                  : "translate-y-8 opacity-0"
              }`}
              style={{ transitionDelay: `${300 + i * 150}ms` }}
            >
              <div className="flex items-start justify-between">
                <span className="inline-flex h-7 w-7 items-center justify-center rounded-full bg-primary/8 text-[11px] font-medium text-primary">
                  {step.number}
                </span>
                <step.icon className="h-5 w-5 text-primary/30" strokeWidth={1.5} />
              </div>

              <h3 className="mt-8 font-serif text-[22px] font-light text-foreground">
                {step.title}
              </h3>

              <p className="mt-4 text-[14px] leading-relaxed text-muted-foreground">
                {step.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

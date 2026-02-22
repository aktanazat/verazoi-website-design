"use client"

import { useEffect, useState } from "react"

export function StabilityScore() {
  const score = 74
  const [displayed, setDisplayed] = useState(0)

  useEffect(() => {
    const timer = setTimeout(() => {
      const step = () => {
        setDisplayed((prev) => {
          if (prev >= score) return score
          return prev + 1
        })
      }
      const interval = setInterval(step, 20)
      return () => clearInterval(interval)
    }, 300)
    return () => clearTimeout(timer)
  }, [])

  const circumference = 2 * Math.PI * 54
  const offset = circumference - (displayed / 100) * circumference

  const getLabel = () => {
    if (displayed >= 80) return "Excellent"
    if (displayed >= 60) return "Good"
    if (displayed >= 40) return "Fair"
    return "Needs attention"
  }

  return (
    <div className="border border-border p-6">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-[12px] uppercase tracking-[0.15em] text-muted-foreground">
            Stability Score
          </p>
          <p className="mt-1 text-[12px] text-muted-foreground/60">
            Last 7 days
          </p>
        </div>
        <span className="border border-border px-2.5 py-1 text-[11px] tracking-[0.02em] text-muted-foreground">
          {getLabel()}
        </span>
      </div>

      <div className="mt-6 flex items-center justify-center">
        <div className="relative">
          <svg width="132" height="132" className="-rotate-90">
            <circle
              cx="66"
              cy="66"
              r="54"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              className="text-border"
            />
            <circle
              cx="66"
              cy="66"
              r="54"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeDasharray={circumference}
              strokeDashoffset={offset}
              strokeLinecap="round"
              className="text-foreground transition-all duration-700 ease-out"
            />
          </svg>
          <div className="absolute inset-0 flex flex-col items-center justify-center">
            <span className="font-serif text-[36px] font-light text-foreground">
              {displayed}
            </span>
          </div>
        </div>
      </div>

      <div className="mt-6 grid grid-cols-3 gap-4">
        <div className="text-center">
          <p className="font-serif text-[18px] font-light text-foreground">92</p>
          <p className="mt-0.5 text-[11px] text-muted-foreground">Avg glucose</p>
        </div>
        <div className="text-center">
          <p className="font-serif text-[18px] font-light text-foreground">18</p>
          <p className="mt-0.5 text-[11px] text-muted-foreground">Variability</p>
        </div>
        <div className="text-center">
          <p className="font-serif text-[18px] font-light text-foreground">94%</p>
          <p className="mt-0.5 text-[11px] text-muted-foreground">In range</p>
        </div>
      </div>
    </div>
  )
}

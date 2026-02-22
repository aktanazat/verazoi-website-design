"use client"

import { useState } from "react"
import { Moon, Footprints } from "lucide-react"

const activityTypes = [
  "Walking", "Running", "Cycling", "Weights", "Yoga", "Swimming", "HIIT", "Other",
] as const

const intensities = ["Light", "Moderate", "Intense"] as const

export default function ActivityPage() {
  const [tab, setTab] = useState<"activity" | "sleep">("activity")

  // Activity state
  const [actType, setActType] = useState<string>("Walking")
  const [duration, setDuration] = useState("")
  const [intensity, setIntensity] = useState<string>("Moderate")

  // Sleep state
  const [sleepHours, setSleepHours] = useState("")
  const [sleepQuality, setSleepQuality] = useState<"poor" | "fair" | "good" | "great">("good")

  const [saved, setSaved] = useState(false)

  const handleSave = () => {
    setSaved(true)
    setTimeout(() => {
      setSaved(false)
      if (tab === "activity") setDuration("")
      else setSleepHours("")
    }, 2000)
  }

  return (
    <div>
      <p className="text-[12px] font-medium uppercase tracking-[0.3em] text-muted-foreground">
        Log
      </p>
      <h1 className="mt-3 font-serif text-[28px] font-light text-foreground">
        {"Activity & Sleep"}
      </h1>

      {/* Tab toggle */}
      <div className="mt-8 grid grid-cols-2 border border-border">
        <button
          onClick={() => setTab("activity")}
          className={`flex items-center justify-center gap-2 py-3 text-[13px] tracking-[0.02em] transition-colors ${
            tab === "activity"
              ? "bg-foreground text-background"
              : "text-muted-foreground hover:text-foreground"
          }`}
        >
          <Footprints className="h-4 w-4" strokeWidth={1.5} />
          Activity
        </button>
        <button
          onClick={() => setTab("sleep")}
          className={`flex items-center justify-center gap-2 py-3 text-[13px] tracking-[0.02em] transition-colors ${
            tab === "sleep"
              ? "bg-foreground text-background"
              : "text-muted-foreground hover:text-foreground"
          }`}
        >
          <Moon className="h-4 w-4" strokeWidth={1.5} />
          Sleep
        </button>
      </div>

      {tab === "activity" ? (
        <div className="mt-8">
          {/* Activity type */}
          <div>
            <label className="text-[12px] uppercase tracking-[0.15em] text-muted-foreground">
              Type
            </label>
            <div className="mt-3 flex flex-wrap gap-2">
              {activityTypes.map((type) => (
                <button
                  key={type}
                  onClick={() => setActType(type)}
                  className={`border px-3.5 py-2 text-[12px] tracking-[0.02em] transition-colors ${
                    actType === type
                      ? "border-foreground bg-foreground text-background"
                      : "border-border text-muted-foreground hover:border-foreground/30"
                  }`}
                >
                  {type}
                </button>
              ))}
            </div>
          </div>

          {/* Duration */}
          <div className="mt-6">
            <label className="text-[12px] uppercase tracking-[0.15em] text-muted-foreground">
              Duration
            </label>
            <div className="mt-3 flex items-baseline gap-2">
              <input
                type="number"
                value={duration}
                onChange={(e) => setDuration(e.target.value)}
                placeholder="0"
                className="w-full bg-transparent font-serif text-[40px] font-light text-foreground placeholder:text-muted-foreground/20 focus:outline-none"
              />
              <span className="text-[14px] text-muted-foreground">minutes</span>
            </div>
          </div>

          {/* Intensity */}
          <div className="mt-6">
            <label className="text-[12px] uppercase tracking-[0.15em] text-muted-foreground">
              Intensity
            </label>
            <div className="mt-3 grid grid-cols-3 gap-2">
              {intensities.map((i) => (
                <button
                  key={i}
                  onClick={() => setIntensity(i)}
                  className={`border py-2.5 text-[12px] tracking-[0.04em] transition-colors ${
                    intensity === i
                      ? "border-foreground bg-foreground text-background"
                      : "border-border text-muted-foreground hover:border-foreground/30"
                  }`}
                >
                  {i}
                </button>
              ))}
            </div>
          </div>
        </div>
      ) : (
        <div className="mt-8">
          {/* Sleep hours */}
          <div>
            <label className="text-[12px] uppercase tracking-[0.15em] text-muted-foreground">
              Hours slept
            </label>
            <div className="mt-3 flex items-baseline gap-2">
              <input
                type="number"
                step="0.5"
                value={sleepHours}
                onChange={(e) => setSleepHours(e.target.value)}
                placeholder="0"
                className="w-full bg-transparent font-serif text-[40px] font-light text-foreground placeholder:text-muted-foreground/20 focus:outline-none"
              />
              <span className="text-[14px] text-muted-foreground">hours</span>
            </div>
          </div>

          {/* Sleep quality */}
          <div className="mt-6">
            <label className="text-[12px] uppercase tracking-[0.15em] text-muted-foreground">
              Quality
            </label>
            <div className="mt-3 grid grid-cols-4 gap-2">
              {(["poor", "fair", "good", "great"] as const).map((q) => (
                <button
                  key={q}
                  onClick={() => setSleepQuality(q)}
                  className={`border py-2.5 text-[12px] capitalize tracking-[0.04em] transition-colors ${
                    sleepQuality === q
                      ? "border-foreground bg-foreground text-background"
                      : "border-border text-muted-foreground hover:border-foreground/30"
                  }`}
                >
                  {q}
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      <button
        onClick={handleSave}
        disabled={tab === "activity" ? !duration : !sleepHours}
        className="mt-8 w-full bg-foreground py-3.5 text-[13px] font-medium tracking-[0.04em] text-background transition-opacity hover:opacity-85 disabled:opacity-30"
      >
        {saved ? "Saved" : tab === "activity" ? "Save activity" : "Save sleep"}
      </button>
    </div>
  )
}

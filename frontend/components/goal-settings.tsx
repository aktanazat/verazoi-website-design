"use client"

import { useState, useEffect } from "react"
import { getGoals, updateGoals, type Goals } from "@/lib/api"

function errorMessage(error: unknown, fallback: string) {
  return error instanceof Error && error.message ? error.message : fallback
}

export function GoalSettings() {
  const [goals, setGoals] = useState<Goals>({ glucose_low: 70, glucose_high: 140, daily_steps: 10000, sleep_hours: 8 })
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)
  const [loadError, setLoadError] = useState<string | null>(null)
  const [saveError, setSaveError] = useState<string | null>(null)

  useEffect(() => {
    let active = true

    async function loadGoals() {
      try {
        const data = await getGoals()
        if (!active) return
        setGoals(data)
        setLoadError(null)
      } catch (error) {
        if (!active) return
        setLoadError(errorMessage(error, "Could not load goals."))
      }
    }

    void loadGoals()

    return () => {
      active = false
    }
  }, [])

  const handleSave = async () => {
    if (saving) return
    setSaving(true)
    setSaveError(null)
    try {
      const updated = await updateGoals(goals)
      setGoals(updated)
      setSaved(true)
      setTimeout(() => setSaved(false), 2000)
    } catch (error) {
      setSaveError(errorMessage(error, "Could not save goals."))
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="rounded-none border border-border bg-card/50 p-5">
      <p className="text-[11px] font-medium uppercase tracking-[0.2em] text-muted-foreground/60">
        Goal Settings
      </p>

      <div className="mt-4 grid grid-cols-2 gap-3">
        <div>
          <label className="text-[11px] text-muted-foreground">Glucose low (mg/dL)</label>
          <input
            type="number"
            value={goals.glucose_low}
            onChange={(e) => setGoals({ ...goals, glucose_low: Number(e.target.value) })}
            className="mt-1 w-full border border-border bg-transparent px-3 py-2 text-[13px] text-foreground focus:border-foreground/30 focus:outline-none"
          />
        </div>
        <div>
          <label className="text-[11px] text-muted-foreground">Glucose high (mg/dL)</label>
          <input
            type="number"
            value={goals.glucose_high}
            onChange={(e) => setGoals({ ...goals, glucose_high: Number(e.target.value) })}
            className="mt-1 w-full border border-border bg-transparent px-3 py-2 text-[13px] text-foreground focus:border-foreground/30 focus:outline-none"
          />
        </div>
        <div>
          <label className="text-[11px] text-muted-foreground">Daily steps</label>
          <input
            type="number"
            value={goals.daily_steps}
            onChange={(e) => setGoals({ ...goals, daily_steps: Number(e.target.value) })}
            className="mt-1 w-full border border-border bg-transparent px-3 py-2 text-[13px] text-foreground focus:border-foreground/30 focus:outline-none"
          />
        </div>
        <div>
          <label className="text-[11px] text-muted-foreground">Sleep (hours)</label>
          <input
            type="number"
            step="0.5"
            value={goals.sleep_hours}
            onChange={(e) => setGoals({ ...goals, sleep_hours: Number(e.target.value) })}
            className="mt-1 w-full border border-border bg-transparent px-3 py-2 text-[13px] text-foreground focus:border-foreground/30 focus:outline-none"
          />
        </div>
      </div>

      <button
        onClick={handleSave}
        disabled={saving}
        className="mt-4 w-full bg-foreground py-2 text-[12px] font-medium tracking-wide text-background disabled:opacity-50"
      >
        {saved ? "Saved" : saving ? "..." : "Save goals"}
      </button>

      {(saveError || loadError) && (
        <p className="mt-3 text-[12px] text-amber-700">
          {saveError ?? loadError}
        </p>
      )}
    </div>
  )
}

"use client"

import { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from "react"
import * as api from "@/lib/api"
import type { GlucoseReading, Meal, TimelineEvent, Activity, SleepEntry, StabilityScore, WearableStatus } from "@/lib/api"

type AppState = {
  glucoseReadings: GlucoseReading[]
  meals: Meal[]
  activities: Activity[]
  sleepEntries: SleepEntry[]
  timeline: TimelineEvent[]
  stability: StabilityScore | null
  wearable: WearableStatus | null
  isLoading: boolean
}

const AppDataContext = createContext<{
  state: AppState
  addGlucoseReading: (value: number, timing: "fasting" | "before" | "after") => Promise<void>
  addMeal: (mealType: string, foods: string[], notes: string) => Promise<void>
  addActivity: (activityType: string, duration: number, intensity: string) => Promise<void>
  addSleep: (hours: number, quality: string) => Promise<void>
  refresh: () => Promise<void>
}>(null!)

export function AppDataProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AppState>({
    glucoseReadings: [],
    meals: [],
    activities: [],
    sleepEntries: [],
    timeline: [],
    stability: null,
    wearable: null,
    isLoading: true,
  })

  const refresh = useCallback(async () => {
    if (!api.getAccessToken()) return

    setState(prev => ({ ...prev, isLoading: true }))

    try {
      const [glucoseReadings, meals, activities, sleepEntries, timeline, stability, wearable] = await Promise.all([
        api.listGlucose(),
        api.listMeals(),
        api.listActivities(),
        api.listSleep(),
        api.listTimeline(),
        api.getStabilityScore(),
        api.getWearableStatus(),
      ])

      setState({
        glucoseReadings,
        meals,
        activities,
        sleepEntries,
        timeline,
        stability,
        wearable,
        isLoading: false,
      })
    } catch {
      setState(prev => ({ ...prev, isLoading: false }))
    }
  }, [])

  useEffect(() => { refresh() }, [refresh])

  const addGlucoseReading = async (value: number, timing: "fasting" | "before" | "after") => {
    await api.createGlucose(value, timing)
    await refresh()
  }

  const addMeal = async (mealType: string, foods: string[], notes: string) => {
    await api.createMeal(mealType, foods, notes)
    await refresh()
  }

  const addActivity = async (activityType: string, duration: number, intensity: string) => {
    await api.createActivity(activityType, duration, intensity)
    await refresh()
  }

  const addSleep = async (hours: number, quality: string) => {
    await api.createSleep(hours, quality)
    await refresh()
  }

  return (
    <AppDataContext.Provider value={{ state, addGlucoseReading, addMeal, addActivity, addSleep, refresh }}>
      {children}
    </AppDataContext.Provider>
  )
}

export function useAppData() {
  return useContext(AppDataContext)
}

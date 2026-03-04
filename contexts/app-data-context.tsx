"use client"

import { createContext, useContext, useReducer, type ReactNode } from "react"

type TimelineEvent = {
  time: string
  type: "glucose" | "meal" | "activity" | "sleep"
  label: string
  value: string
}

type GlucoseReading = {
  time: string
  value: number
  timing: "fasting" | "before" | "after"
}

type Meal = {
  time: string
  mealType: string
  foods: string[]
  notes: string
}

type ActivityEntry = {
  time: string
  activityType: string
  duration: number
  intensity: string
}

type SleepEntry = {
  time: string
  hours: number
  quality: string
}

type AppState = {
  meals: Meal[]
  glucoseReadings: GlucoseReading[]
  activities: ActivityEntry[]
  sleepEntries: SleepEntry[]
  timeline: TimelineEvent[]
  stabilityScore: number
}

type Action =
  | { type: "addMeal"; payload: Meal }
  | { type: "addGlucoseReading"; payload: GlucoseReading }
  | { type: "addActivity"; payload: ActivityEntry }
  | { type: "addSleep"; payload: SleepEntry }

const seedTimeline: TimelineEvent[] = [
  { time: "7:00 AM", type: "glucose", label: "Fasting", value: "88 mg/dL" },
  { time: "7:45 AM", type: "meal", label: "Breakfast", value: "Oatmeal, berries" },
  { time: "8:15 AM", type: "activity", label: "Morning walk", value: "25 min, light" },
  { time: "9:30 AM", type: "glucose", label: "Post-meal", value: "112 mg/dL" },
  { time: "12:30 PM", type: "meal", label: "Lunch", value: "Grilled chicken, salad" },
  { time: "2:00 PM", type: "glucose", label: "Post-meal", value: "104 mg/dL" },
  { time: "5:30 PM", type: "activity", label: "Yoga", value: "45 min, moderate" },
  { time: "11:00 PM", type: "sleep", label: "Sleep logged", value: "5.5 hrs, fair" },
]

const seedGlucose: GlucoseReading[] = [
  { time: "7:00 AM", value: 88, timing: "fasting" },
  { time: "9:30 AM", value: 112, timing: "after" },
  { time: "2:00 PM", value: 104, timing: "after" },
]

const initialState: AppState = {
  meals: [],
  glucoseReadings: seedGlucose,
  activities: [],
  sleepEntries: [],
  timeline: seedTimeline,
  stabilityScore: 74,
}

function recalcScore(state: AppState): number {
  let score = 74
  for (const r of state.glucoseReadings.slice(seedGlucose.length)) {
    if (r.value >= 70 && r.value <= 140) score += 0.5
    else score -= 1
  }
  score += state.activities.length * 0.5
  for (const s of state.sleepEntries) {
    if (s.hours >= 7 && (s.quality === "good" || s.quality === "great")) score += 0.5
    else score -= 0.5
  }
  return Math.max(0, Math.min(100, Math.round(score)))
}

function nowTime(): string {
  return new Date().toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit", hour12: true })
}

function reducer(state: AppState, action: Action): AppState {
  switch (action.type) {
    case "addMeal": {
      const event: TimelineEvent = {
        time: nowTime(),
        type: "meal",
        label: action.payload.mealType,
        value: action.payload.foods.join(", "),
      }
      const next = {
        ...state,
        meals: [...state.meals, action.payload],
        timeline: [...state.timeline, event],
      }
      return { ...next, stabilityScore: recalcScore(next) }
    }
    case "addGlucoseReading": {
      const timingLabel = action.payload.timing === "fasting" ? "Fasting" : action.payload.timing === "before" ? "Pre-meal" : "Post-meal"
      const event: TimelineEvent = {
        time: nowTime(),
        type: "glucose",
        label: timingLabel,
        value: `${action.payload.value} mg/dL`,
      }
      const next = {
        ...state,
        glucoseReadings: [...state.glucoseReadings, action.payload],
        timeline: [...state.timeline, event],
      }
      return { ...next, stabilityScore: recalcScore(next) }
    }
    case "addActivity": {
      const event: TimelineEvent = {
        time: nowTime(),
        type: "activity",
        label: action.payload.activityType,
        value: `${action.payload.duration} min, ${action.payload.intensity.toLowerCase()}`,
      }
      const next = {
        ...state,
        activities: [...state.activities, action.payload],
        timeline: [...state.timeline, event],
      }
      return { ...next, stabilityScore: recalcScore(next) }
    }
    case "addSleep": {
      const event: TimelineEvent = {
        time: nowTime(),
        type: "sleep",
        label: "Sleep logged",
        value: `${action.payload.hours} hrs, ${action.payload.quality}`,
      }
      const next = {
        ...state,
        sleepEntries: [...state.sleepEntries, action.payload],
        timeline: [...state.timeline, event],
      }
      return { ...next, stabilityScore: recalcScore(next) }
    }
  }
}

const AppDataContext = createContext<{
  state: AppState
  dispatch: React.Dispatch<Action>
}>(null!)

export function AppDataProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(reducer, initialState)
  return (
    <AppDataContext.Provider value={{ state, dispatch }}>
      {children}
    </AppDataContext.Provider>
  )
}

export function useAppData() {
  return useContext(AppDataContext)
}

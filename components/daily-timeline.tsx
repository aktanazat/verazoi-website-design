import { Droplets, Utensils, Footprints, Moon } from "lucide-react"

const events = [
  { time: "7:00 AM", type: "glucose", icon: Droplets, label: "Fasting", value: "88 mg/dL" },
  { time: "7:45 AM", type: "meal", icon: Utensils, label: "Breakfast", value: "Oatmeal, berries" },
  { time: "8:15 AM", type: "activity", icon: Footprints, label: "Morning walk", value: "25 min, light" },
  { time: "9:30 AM", type: "glucose", icon: Droplets, label: "Post-meal", value: "112 mg/dL" },
  { time: "12:30 PM", type: "meal", icon: Utensils, label: "Lunch", value: "Grilled chicken, salad" },
  { time: "2:00 PM", type: "glucose", icon: Droplets, label: "Post-meal", value: "104 mg/dL" },
  { time: "5:30 PM", type: "activity", icon: Footprints, label: "Yoga", value: "45 min, moderate" },
  { time: "11:00 PM", type: "sleep", icon: Moon, label: "Sleep logged", value: "5.5 hrs, fair" },
]

export function DailyTimeline() {
  return (
    <div className="border border-border p-6">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-[12px] uppercase tracking-[0.15em] text-muted-foreground">
            {"Today's Log"}
          </p>
          <p className="mt-1 text-[12px] text-muted-foreground/60">
            {events.length} entries
          </p>
        </div>
      </div>

      <div className="mt-6">
        {events.map((event, i) => (
          <div key={i} className="flex gap-4">
            {/* Timeline line */}
            <div className="flex flex-col items-center">
              <div className="flex h-7 w-7 items-center justify-center border border-border">
                <event.icon className="h-3 w-3 text-muted-foreground" strokeWidth={1.5} />
              </div>
              {i < events.length - 1 && (
                <div className="w-px flex-1 bg-border" />
              )}
            </div>

            {/* Content */}
            <div className={`flex-1 ${i < events.length - 1 ? "pb-5" : ""}`}>
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-[13px] text-foreground">{event.label}</p>
                  <p className="mt-0.5 text-[12px] text-muted-foreground">{event.value}</p>
                </div>
                <span className="text-[11px] text-muted-foreground/50">{event.time}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

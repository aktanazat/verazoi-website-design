import Foundation
import Observation

@Observable
final class AppState {
    var meals: [Meal] = []
    var glucoseReadings: [GlucoseReading] = []
    var activities: [ActivityEntry] = []
    var sleepEntries: [SleepEntry] = []
    var medications: [MedicationEntry] = []
    var timeline: [TimelineEvent] = []
    var stabilityScore: Int = 0
    var stabilityResult: StabilityResult?
    var isSyncing = false
    var goals = UserGoals()
    var goalProgress = GoalProgress()
    var glucoseTrend: [GlucoseTrendPoint] = []
    var stabilityTrend: [StabilityTrendPoint] = []
    var foodImpacts: [FoodImpact] = []
    var weeklyInsight: WeeklyInsight?
    var weeklyInsightPreview: WeeklyInsightPreview?
    var fetchError: String?
    var isLoadingTrends = false
    var isLoadingFoodImpact = false

    weak var wearable: WearableState?

    private func nowTime() -> String {
        Date().formatted(date: .omitted, time: .shortened)
    }

    func recalcScore() {
        let input = StabilityInput(
            glucoseReadings: glucoseReadings,
            activities: activities,
            sleepEntries: sleepEntries,
            wearableHeartRate: wearable?.latestHeartRate,
            wearableSteps: wearable?.todaySteps,
            wearableActiveMinutes: wearable?.todayActiveMinutes,
            wearableSleepHours: wearable?.lastSleepHours
        )
        let result = StabilityAlgorithm.calculate(input: input)
        stabilityScore = result.score
        stabilityResult = result

        NotificationManager.shared.checkAndNotifySpike(risk: result.spikeRisk)
        updateWidgetData()
    }

    private func updateWidgetData() {
        let defaults = UserDefaults(suiteName: "group.verazoi.app")
        defaults?.set(stabilityScore, forKey: "widget_stability_score")
        defaults?.set(Int((stabilityResult?.spikeRisk ?? 0) * 100), forKey: "widget_spike_risk")
        if let last = glucoseReadings.last {
            defaults?.set(last.value, forKey: "widget_last_glucose")
            defaults?.set(last.time, forKey: "widget_last_glucose_time")
        }
    }

    func addGlucoseReading(value: Int, timing: GlucoseTiming) {
        let time = nowTime()
        glucoseReadings.append(GlucoseReading(time: time, value: value, timing: timing))
        timeline.append(TimelineEvent(time: time, type: .glucose, label: timing.displayName, value: "\(value) mg/dL"))
        recalcScore()
        Task { try? await APIClient.shared.createGlucose(value: value, timing: timing.rawValue) }
    }

    func addMeal(mealType: String, foods: [String], notes: String) {
        let time = nowTime()
        meals.append(Meal(time: time, mealType: mealType, foods: foods, notes: notes))
        timeline.append(TimelineEvent(time: time, type: .meal, label: mealType, value: foods.joined(separator: ", ")))
        Task { try? await APIClient.shared.createMeal(mealType: mealType, foods: foods, notes: notes) }
    }

    func addActivity(activityType: String, duration: Int, intensity: String) {
        let time = nowTime()
        activities.append(ActivityEntry(time: time, activityType: activityType, duration: duration, intensity: intensity))
        timeline.append(TimelineEvent(time: time, type: .activity, label: activityType, value: "\(duration) min, \(intensity.lowercased())"))
        recalcScore()
        Task { try? await APIClient.shared.createActivity(activityType: activityType, duration: duration, intensity: intensity) }
    }

    func addSleep(hours: Double, quality: String) {
        let time = nowTime()
        sleepEntries.append(SleepEntry(time: time, hours: hours, quality: quality))
        timeline.append(TimelineEvent(time: time, type: .sleep, label: "Sleep logged", value: "\(hours) hrs, \(quality)"))
        recalcScore()
        Task { try? await APIClient.shared.createSleep(hours: hours, quality: quality) }
    }

    func addMedication(name: String, doseValue: Double, doseUnit: String, timing: String, notes: String) {
        let time = nowTime()
        medications.append(MedicationEntry(time: time, name: name, doseValue: doseValue, doseUnit: doseUnit, timing: timing, notes: notes))
        timeline.append(TimelineEvent(time: time, type: .medication, label: name, value: "\(doseValue) \(doseUnit)"))
        Task { try? await APIClient.shared.createMedication(name: name, doseValue: doseValue, doseUnit: doseUnit, timing: timing, notes: notes) }
    }

    static func clearWidgetData() {
        let defaults = UserDefaults(suiteName: "group.verazoi.app")
        defaults?.removeObject(forKey: "widget_stability_score")
        defaults?.removeObject(forKey: "widget_spike_risk")
        defaults?.removeObject(forKey: "widget_last_glucose")
        defaults?.removeObject(forKey: "widget_last_glucose_time")
    }

    private func removeTimelineEvent(type: EventType, at index: Int) {
        let events = timeline.filter { $0.type == type }
        if index < events.count {
            timeline.removeAll { $0.id == events[index].id }
        }
    }

    func deleteGlucoseReading(at index: Int) {
        removeTimelineEvent(type: .glucose, at: index)
        glucoseReadings.remove(at: index)
        recalcScore()
    }

    func deleteActivity(at index: Int) {
        removeTimelineEvent(type: .activity, at: index)
        activities.remove(at: index)
        recalcScore()
    }

    func deleteSleep(at index: Int) {
        removeTimelineEvent(type: .sleep, at: index)
        sleepEntries.remove(at: index)
        recalcScore()
    }

    func deleteMedication(at index: Int) {
        removeTimelineEvent(type: .medication, at: index)
        medications.remove(at: index)
        recalcScore()
    }

    func fetchFromBackend() async {
        isSyncing = true
        fetchError = nil
        do {
            async let glucoseTask = APIClient.shared.listGlucose()
            async let mealsTask = APIClient.shared.listMeals()
            async let activitiesTask = APIClient.shared.listActivities()
            async let sleepTask = APIClient.shared.listSleep()
            async let timelineTask = APIClient.shared.listTimeline()
            async let scoreTask = APIClient.shared.getStabilityScore()
            async let medsTask = APIClient.shared.listMedications()
            async let goalsTask = APIClient.shared.getGoals()
            async let progressTask = APIClient.shared.getGoalProgress()

            let (remoteGlucose, remoteMeals, remoteActivities, remoteSleep, remoteTimeline, serverScore, remoteMeds, remoteGoals, remoteProgress) = try await (
                glucoseTask, mealsTask, activitiesTask, sleepTask, timelineTask, scoreTask, medsTask, goalsTask, progressTask
            )

            glucoseReadings = remoteGlucose.map {
                GlucoseReading(time: $0.recordedAt.formatted(date: .omitted, time: .shortened), value: $0.value, timing: GlucoseTiming(rawValue: $0.timing) ?? .fasting)
            }
            meals = remoteMeals.map {
                Meal(time: $0.recordedAt.formatted(date: .omitted, time: .shortened), mealType: $0.mealType, foods: $0.foods, notes: $0.notes)
            }
            activities = remoteActivities.map {
                ActivityEntry(time: $0.recordedAt.formatted(date: .omitted, time: .shortened), activityType: $0.activityType, duration: $0.duration, intensity: $0.intensity)
            }
            sleepEntries = remoteSleep.map {
                SleepEntry(time: $0.recordedAt.formatted(date: .omitted, time: .shortened), hours: $0.hours, quality: $0.quality)
            }
            timeline = remoteTimeline.map {
                TimelineEvent(time: $0.recordedAt.formatted(date: .omitted, time: .shortened), type: EventType(rawValue: $0.type) ?? .glucose, label: $0.label, value: $0.value)
            }
            medications = remoteMeds.map {
                MedicationEntry(time: $0.recordedAt.formatted(date: .omitted, time: .shortened), name: $0.name, doseValue: $0.doseValue, doseUnit: $0.doseUnit, timing: $0.timing, notes: $0.notes)
            }
            stabilityScore = serverScore.score
            goals = UserGoals(glucoseLow: remoteGoals.glucoseLow, glucoseHigh: remoteGoals.glucoseHigh, dailySteps: remoteGoals.dailySteps, sleepHours: remoteGoals.sleepHours)
            goalProgress = GoalProgress(glucoseInRangePct: remoteProgress.glucoseInRangePct, stepsToday: remoteProgress.stepsToday, stepsTarget: remoteProgress.stepsTarget, sleepLast: remoteProgress.sleepLast, sleepTarget: remoteProgress.sleepTarget)
        } catch {
            fetchError = "Could not load data. Pull down to retry."
            recalcScore()
        }
        isSyncing = false
    }

    func fetchTrends(days: Int = 7) async {
        isLoadingTrends = true
        do {
            async let gt = APIClient.shared.getGlucoseTrend(days: days)
            async let st = APIClient.shared.getStabilityTrend(days: days)
            let (glucoseT, stabilityT) = try await (gt, st)
            glucoseTrend = glucoseT.map { GlucoseTrendPoint(date: $0.date, avg: $0.avg, min: $0.min, max: $0.max) }
            stabilityTrend = stabilityT.map { StabilityTrendPoint(date: $0.date, score: $0.score) }
        } catch {}
        isLoadingTrends = false
    }

    func fetchFoodImpact() async {
        isLoadingFoodImpact = true
        do {
            let impacts = try await APIClient.shared.getFoodImpact()
            foodImpacts = impacts.map { FoodImpact(food: $0.food, avgDelta: $0.avgDelta, occurrences: $0.occurrences) }
        } catch {}
        isLoadingFoodImpact = false
    }

    func fetchInsight() async {
        do {
            let insight = try await APIClient.shared.getWeeklyInsight()
            weeklyInsight = WeeklyInsight(id: insight.id, weekStart: insight.weekStart, summary: insight.summary, generatedAt: insight.generatedAt)
        } catch {}
    }

    func fetchInsightPreview() async {
        guard let preview = try? await APIClient.shared.getWeeklyInsightPreview() else {
            weeklyInsightPreview = nil
            return
        }

        weeklyInsightPreview = WeeklyInsightPreview(
            weekStart: preview.weekStart,
            weekEnd: preview.weekEnd,
            systemPrompt: preview.systemPrompt,
            userPrompt: preview.userPrompt
        )
    }

    func generateInsight() async {
        guard let preview = weeklyInsightPreview else { return }
        do {
            let insight = try await APIClient.shared.generateWeeklyInsight(weekStart: preview.weekStart, userPrompt: preview.userPrompt)
            weeklyInsight = WeeklyInsight(id: insight.id, weekStart: insight.weekStart, summary: insight.summary, generatedAt: insight.generatedAt)
        } catch {}
    }

    func syncWearableToBackend() {
        guard let w = wearable else { return }
        Task {
            if (try? await APIClient.shared.syncWearable(
                heartRate: w.latestHeartRate, steps: w.todaySteps,
                activeMinutes: w.todayActiveMinutes, sleepHours: w.lastSleepHours,
                sleepQuality: w.lastSleepQuality, glucoseReadings: w.latestGlucoseReadings
            )) != nil {
                await fetchFromBackend()
            }
        }
    }
}

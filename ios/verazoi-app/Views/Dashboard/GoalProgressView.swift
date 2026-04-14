import SwiftUI

struct GoalProgressView: View {
    let progress: GoalProgress

    var body: some View {
        VCard {
            VStack(alignment: .leading, spacing: 0) {
                VLabelText(text: "Goal Progress")

                VStack(spacing: 16) {
                    ProgressRow(
                        label: "Glucose in range",
                        current: "\(Int(progress.glucoseInRangePct))%",
                        fraction: progress.glucoseInRangePct / 100
                    )
                    ProgressRow(
                        label: "Steps",
                        current: "\(progress.stepsToday) / \(progress.stepsTarget)",
                        fraction: progress.stepsTarget > 0
                            ? Double(progress.stepsToday) / Double(progress.stepsTarget)
                            : 0
                    )
                    ProgressRow(
                        label: "Sleep",
                        current: "\(String(format: "%.1f", progress.sleepLast)) / \(String(format: "%.0f", progress.sleepTarget)) hrs",
                        fraction: progress.sleepTarget > 0
                            ? progress.sleepLast / progress.sleepTarget
                            : 0
                    )
                }
                .padding(.top, 16)
            }
        }
    }
}

private struct ProgressRow: View {
    let label: String
    let current: String
    let fraction: Double

    private var clampedFraction: Double {
        min(max(fraction, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.vForeground)
                Spacer()
                Text(current)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.vMutedForeground)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.vBorder)
                        .frame(height: 4)

                    Rectangle()
                        .fill(Color.vPrimary)
                        .frame(width: geo.size.width * clampedFraction, height: 4)
                }
            }
            .frame(height: 4)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(label): \(current), \(Int(clampedFraction * 100)) percent")
        }
    }
}

import SwiftUI

struct FastingView: View {
    @State private var isActive = false
    @State private var startedAt: Date?
    @State private var targetHours: Double = 16
    @State private var history: [(id: String, started: String, elapsed: Double, target: Double?)] = []
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VCard {
                    VStack(spacing: 0) {
                        VLabelText(text: "Fasting Timer")

                        if isActive, let startedAt {
                            TimelineView(.periodic(from: .now, by: 60)) { context in
                                let elapsed = context.date.timeIntervalSince(startedAt) / 3600
                                Text(formatElapsed(elapsed))
                                    .font(.vSerif(48))
                                    .foregroundStyle(Color.vForeground)
                                    .monospacedDigit()

                                if targetHours > 0 {
                                    let progress = min(elapsed / targetHours, 1.0)
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Color.vBorder)
                                                .frame(height: 4)
                                            Rectangle()
                                                .fill(Color.vPrimary)
                                                .frame(width: geo.size.width * progress, height: 4)
                                        }
                                    }
                                    .frame(height: 4)
                                    .padding(.top, 16)

                                    Text("\(Int(targetHours))h target")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.vMutedForeground)
                                        .padding(.top, 8)
                                }
                            }
                            .padding(.top, 20)

                            Text("Started \(startedAt.formatted(date: .omitted, time: .shortened))")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.vMutedForeground)
                                .padding(.top, 4)

                            Button {
                                endFast()
                            } label: {
                                Text("End Fast")
                                    .font(.system(size: 12, weight: .medium))
                                    .tracking(0.4)
                                    .foregroundStyle(Color.vBackground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.vForeground)
                            }
                            .padding(.top, 20)
                        } else {
                            Text("Track how fasting affects your glucose levels.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.vMutedForeground)
                                .lineSpacing(4)
                                .padding(.top, 12)

                            VLabelText(text: "Target duration")
                                .padding(.top, 20)

                            HStack(spacing: 8) {
                                ForEach([12.0, 16.0, 18.0, 24.0], id: \.self) { hours in
                                    VPillButton(title: "\(Int(hours))h", isSelected: targetHours == hours) {
                                        targetHours = hours
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.top, 8)

                            Button {
                                startFast()
                            } label: {
                                Text("Start Fast")
                                    .font(.system(size: 12, weight: .medium))
                                    .tracking(0.4)
                                    .foregroundStyle(Color.vBackground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.vForeground)
                            }
                            .padding(.top, 20)
                        }
                    }
                }

                if !history.isEmpty {
                    VCard {
                        VStack(alignment: .leading, spacing: 0) {
                            VLabelText(text: "History")

                            VStack(spacing: 0) {
                                ForEach(history, id: \.id) { session in
                                    HStack {
                                        Text(formatElapsed(session.elapsed))
                                            .font(.system(size: 14, weight: .medium))
                                            .monospacedDigit()
                                            .foregroundStyle(Color.vForeground)
                                        if let target = session.target {
                                            Text("/ \(Int(target))h")
                                                .font(.system(size: 12))
                                                .foregroundStyle(Color.vMutedForeground)
                                        }
                                        Spacer()
                                        Text(session.started)
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.vMutedForeground)
                                    }
                                    .padding(.vertical, 10)
                                    Divider().foregroundStyle(Color.vBorder)
                                }
                            }
                            .padding(.top, 12)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .task { await loadState() }
    }

    private func formatElapsed(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return String(format: "%d:%02d", h, m)
    }

    private func startFast() {
        Task {
            let session = try? await APIClient.shared.startFast(targetHours: targetHours)
            if session != nil {
                startedAt = Date()
                isActive = true
            }
        }
    }

    private func endFast() {
        Task {
            _ = try? await APIClient.shared.endFast()
            isActive = false
            await loadState()
        }
    }

    private func loadState() async {
        if let active = try? await APIClient.shared.getActiveFast() {
            isActive = true
            targetHours = active.targetHours ?? 16
            let formatter = ISO8601DateFormatter()
            startedAt = formatter.date(from: active.startedAt)
        }

        let sessions = (try? await APIClient.shared.fastingHistory()) ?? []
        history = sessions.map { s in
            (id: s.id, started: s.startedAt, elapsed: s.elapsedHours, target: s.targetHours)
        }
    }
}

import SwiftUI
import HealthKit

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var healthKitAuthorized = false
    let onComplete: () -> Void

    private let pageCount = 4

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                WelcomePage(advance: nextPage)
                    .background(Color.vBackground)
                    .tag(0)

                TrackingPage(advance: nextPage)
                    .background(Color.vBackground)
                    .tag(1)

                ScorePage(advance: nextPage)
                    .background(Color.vBackground)
                    .tag(2)

                HealthDataPage(
                    authorized: $healthKitAuthorized,
                    onComplete: onComplete
                )
                .background(Color.vBackground)
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Color.vBackground)
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            PageIndicator(current: currentPage, total: pageCount)
                .padding(.bottom, 48)
        }
        .background(Color.vBackground)
    }

    private func nextPage() {
        currentPage = min(currentPage + 1, pageCount - 1)
    }
}

// MARK: - Page 1: Welcome

private struct WelcomePage: View {
    let advance: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image("VerazoiLogoFull")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)

                Text("METABOLIC INTELLIGENCE")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(4)
                    .foregroundStyle(Color.vMutedForeground)
            }

            Spacer()
                .frame(height: 56)

            VStack(spacing: 16) {
                Text("Know your body.\nOwn your data.")
                    .font(.vSerif(28, weight: .regular))
                    .foregroundStyle(Color.vForeground)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("Verazoi turns continuous glucose data into a single stability score that reflects how your metabolism actually responds to food, movement, and sleep.")
                    .font(.vBody())
                    .foregroundStyle(Color.vMutedForeground)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }

            Spacer()

            OnboardingButton(title: "Get started", action: advance)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
    }
}

// MARK: - Page 2: What You Track

private struct TrackingPage: View {
    let advance: () -> Void

    private let items: [(icon: String, label: String, detail: String)] = [
        ("drop.fill", "GLUCOSE", "Continuous readings from your CGM sensor"),
        ("fork.knife", "MEALS", "Log what you eat, photograph plates for recognition"),
        ("figure.run", "ACTIVITY", "Steps, workouts, and active minutes"),
        ("bed.double.fill", "SLEEP", "Duration and quality from your wearable"),
        ("heart.fill", "HEART RATE", "Resting and active heart rate data"),
        ("pills.fill", "MEDICATIONS", "Track meds and set schedule reminders"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)

            VStack(spacing: 8) {
                VLabelText(text: "What you track")

                Text("Six data streams.\nOne picture.")
                    .font(.vSerif(26, weight: .regular))
                    .foregroundStyle(Color.vForeground)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
                .frame(height: 36)

            VStack(spacing: 0) {
                ForEach(items, id: \.label) { item in
                    HStack(spacing: 16) {
                        Image(systemName: item.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.vPrimary)
                            .frame(width: 28, alignment: .center)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.label)
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(1.2)
                                .foregroundStyle(Color.vForeground)

                            Text(item.detail)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.vMutedForeground)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 32)

                    if item.label != items.last?.label {
                        Divider()
                            .background(Color.vBorder)
                            .padding(.leading, 76)
                    }
                }
            }

            Spacer()

            OnboardingButton(title: "Continue", action: advance)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
    }
}

// MARK: - Page 3: Stability Score

private struct ScorePage: View {
    let advance: () -> Void
    @State private var animatedScore = 0

    private let components: [(label: String, weight: String)] = [
        ("Glucose variability", "35%"),
        ("Activity level", "25%"),
        ("Sleep quality", "20%"),
        ("Resting heart rate", "20%"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)

            VStack(spacing: 8) {
                VLabelText(text: "Your score")

                Text("Metabolic stability,\nquantified.")
                    .font(.vSerif(26, weight: .regular))
                    .foregroundStyle(Color.vForeground)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
                .frame(height: 32)

            ZStack {
                Circle()
                    .stroke(Color.vBorder, lineWidth: 2)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(animatedScore) / 100)
                    .stroke(Color.vPrimary, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                Text("\(animatedScore)")
                    .font(.vSerif(40, weight: .light))
                    .foregroundStyle(Color.vForeground)
                    .contentTransition(.numericText())
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Example stability score: 78 out of 100")
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    animatedScore = 78
                }
            }

            Spacer()
                .frame(height: 32)

            VStack(spacing: 0) {
                ForEach(components, id: \.label) { component in
                    HStack {
                        Text(component.label)
                            .font(.vBody())
                            .foregroundStyle(Color.vForeground)

                        Spacer()

                        Text(component.weight)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.vMutedForeground)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 40)

                    if component.label != components.last?.label {
                        Divider()
                            .background(Color.vBorder)
                            .padding(.horizontal, 40)
                    }
                }
            }

            Text("Updated throughout the day as new data arrives.")
                .font(.system(size: 11))
                .foregroundStyle(Color.vMutedForeground)
                .padding(.top, 16)

            Spacer()

            OnboardingButton(title: "Continue", action: advance)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
    }
}

// MARK: - Page 4: Health Data

private struct HealthDataPage: View {
    @Binding var authorized: Bool
    let onComplete: () -> Void
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 80)

            VStack(spacing: 8) {
                VLabelText(text: "Permissions")

                Text("Connect Apple Health")
                    .font(.vSerif(26, weight: .regular))
                    .foregroundStyle(Color.vForeground)
                    .multilineTextAlignment(.center)
            }

            Spacer()
                .frame(height: 24)

            Text("Verazoi reads glucose, heart rate, steps, exercise time, and sleep from Apple Health to calculate your stability score. No data is written back.")
                .font(.vBody())
                .foregroundStyle(Color.vMutedForeground)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)

            Spacer()
                .frame(height: 32)

            VStack(spacing: 12) {
                PermissionRow(icon: "drop.fill", label: "Blood glucose")
                PermissionRow(icon: "heart.fill", label: "Heart rate & resting HR")
                PermissionRow(icon: "figure.walk", label: "Step count")
                PermissionRow(icon: "flame.fill", label: "Exercise minutes")
                PermissionRow(icon: "bed.double.fill", label: "Sleep analysis")
            }
            .padding(.horizontal, 40)

            Spacer()
                .frame(height: 20)

            if authorized {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Health data connected")
                        .font(.system(size: 13, weight: .medium))
                        .tracking(0.3)
                }
                .foregroundStyle(Color.vPrimary)
                .padding(.top, 8)
            }

            Spacer()

            VStack(spacing: 12) {
                if !authorized {
                    OnboardingButton(title: "Allow Health access", isLoading: isRequesting) {
                        requestHealthKit()
                    }
                } else {
                    OnboardingButton(title: "Continue", action: onComplete)
                }

                Button(action: onComplete) {
                    Text(authorized ? "" : "Skip for now")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.vMutedForeground)
                }
                .opacity(authorized ? 0 : 1)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 16)
        }
    }

    private func requestHealthKit() {
        isRequesting = true
        Task {
            let hk = HealthKitManager.shared
            guard await hk.isAvailable else {
                isRequesting = false
                return
            }
            do {
                try await hk.requestAuthorization()
                authorized = true
            } catch {}
            isRequesting = false
        }
    }
}

// MARK: - Components

private struct PermissionRow: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.vPrimary)
                .frame(width: 24, alignment: .center)

            Text(label)
                .font(.vBody())
                .foregroundStyle(Color.vForeground)

            Spacer()

            Text("READ")
                .font(.system(size: 9, weight: .semibold))
                .tracking(1)
                .foregroundStyle(Color.vMutedForeground)
        }
        .padding(.vertical, 8)
    }
}

private struct OnboardingButton: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(Color.vBackground)
                } else {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .tracking(0.5)
                }
            }
            .foregroundStyle(Color.vBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.vForeground)
        }
    }
}

private struct PageIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == current ? Color.vForeground : Color.vBorder)
                    .frame(width: index == current ? 20 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: current)
            }
        }
    }
}

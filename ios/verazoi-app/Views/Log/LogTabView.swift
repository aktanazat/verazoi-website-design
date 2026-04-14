import SwiftUI

enum LogTab: String, CaseIterable {
    case glucose = "Glucose"
    case meals = "Meals"
    case activity = "Activity"
    case sleep = "Sleep"
    case medications = "Meds"
    case fasting = "Fasting"
    case experiments = "A/B Test"

    var icon: String {
        switch self {
        case .glucose: return "drop.fill"
        case .meals: return "fork.knife"
        case .activity: return "figure.run"
        case .sleep: return "bed.double.fill"
        case .medications: return "pills.fill"
        case .fasting: return "hourglass"
        case .experiments: return "flask.fill"
        }
    }
}

struct LogTabView: View {
    @State private var selectedTab: LogTab = .glucose
    @Environment(\.design) private var design

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(LogTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            if design.useIconTabs {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                                    .foregroundStyle(selectedTab == tab ? Color.vPrimary : Color.vMutedForeground.opacity(0.72))
                                    .frame(width: 46, height: 46)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(selectedTab == tab ? Color.vCard : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(selectedTab == tab ? Color.vBorder.opacity(0.9) : Color.clear, lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(selectedTab == tab ? 0.06 : 0), radius: 10, y: 3)
                                    .accessibilityLabel(tab.rawValue)
                                    .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
                                    .contentShape(RoundedRectangle(cornerRadius: 15))
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            } else {
                                Text(tab.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                    .tracking(0.3)
                                    .foregroundStyle(selectedTab == tab ? Color.vForeground : Color.vMutedForeground.opacity(0.7))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedTab == tab ? Color.vPrimary.opacity(0.1) : Color.clear)
                                    .clipShape(Capsule())
                            }
                        }
                        .accessibilityHint("Switch to \(tab.rawValue)")
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 12)

            if design.useIconTabs {
                Text(selectedTab.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .tracking(0.3)
                    .foregroundStyle(Color.vMutedForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
            } else {
                Color.clear.frame(height: 12)
            }

            switch selectedTab {
            case .glucose: GlucoseLogView()
            case .meals: MealsLogView()
            case .activity: ActivityLogView()
            case .sleep: SleepLogView()
            case .medications: MedicationLogView()
            case .fasting: FastingView()
            case .experiments: ExperimentsView()
            }
        }
        .background(Color.vBackground)
    }
}

import SwiftUI

enum AppTab: String {
    case dashboard = "Dashboard"
    case log = "Log"
    case settings = "Settings"
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var appState = AppState()
    @State private var wearableState = WearableState()
    @State private var authState = AuthState()
    @AppStorage("verazoi_onboarding_complete") private var onboardingComplete = false
    @AppStorage("verazoi_design_variant") private var variantRaw = "classic"

    private var design: DesignVariant {
        DesignVariant(rawValue: variantRaw) ?? .classic
    }

    var body: some View {
        Group {
            if !onboardingComplete {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        onboardingComplete = true
                    }
                }
            } else if authState.isAuthenticated {
                TabView(selection: $selectedTab) {
                    Tab("Dashboard", systemImage: design == .soft ? "heart.text.clipboard.fill" : "chart.bar", value: .dashboard) {
                        DashboardView()
                    }

                    Tab("Log", systemImage: design == .soft ? "plus.circle.fill" : "square.and.pencil", value: .log) {
                        LogTabView()
                    }

                    Tab("Settings", systemImage: design == .soft ? "gearshape.fill" : "gearshape", value: .settings) {
                        SettingsView()
                    }
                }
                .tint(Color.vPrimary)
            } else {
                LoginView()
            }
        }
        .environment(\.design, design)
        .environment(appState)
        .environment(wearableState)
        .environment(authState)
        .onAppear {
            appState.wearable = wearableState
        }
        .onChange(of: authState.isAuthenticated) {
            if authState.isAuthenticated {
                Task { await appState.fetchFromBackend() }
            }
        }
        .onChange(of: wearableState.lastSyncDate) {
            appState.recalcScore()
            appState.syncWearableToBackend()
        }
    }
}

#Preview {
    ContentView()
}

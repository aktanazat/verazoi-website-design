import Foundation
import Observation

@Observable
final class AuthState {
    var isAuthenticated = false
    var token: String?
    var email: String?
    var isLoading = false
    var error: String?
    var sessionExpired = false

    private let tokenKey = "verazoi_token"
    private let emailKey = "verazoi_email"

    init() {
        if let saved = UserDefaults.standard.string(forKey: tokenKey) {
            token = saved
            email = UserDefaults.standard.string(forKey: emailKey)
            isAuthenticated = true
            Task { await APIClient.shared.setToken(saved) }
        }
        Task {
            await APIClient.shared.setSessionExpiredHandler { [weak self] in
                Task { @MainActor in
                    self?.sessionExpired = true
                    self?.logout()
                }
            }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            let t = try await APIClient.shared.login(email: email, password: password)
            token = t
            self.email = email
            isAuthenticated = true
            UserDefaults.standard.set(t, forKey: tokenKey)
            UserDefaults.standard.set(email, forKey: emailKey)
        } catch let e as APIError {
            switch e {
            case .httpError(_, let detail): error = detail
            default: error = "Connection failed"
            }
        } catch {
            self.error = "Connection failed"
        }
        isLoading = false
    }

    func register(email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            let t = try await APIClient.shared.register(email: email, password: password)
            token = t
            self.email = email
            isAuthenticated = true
            UserDefaults.standard.set(t, forKey: tokenKey)
            UserDefaults.standard.set(email, forKey: emailKey)
        } catch let e as APIError {
            switch e {
            case .httpError(_, let detail): error = detail
            default: error = "Connection failed"
            }
        } catch {
            self.error = "Connection failed"
        }
        isLoading = false
    }

    func forgotPassword(email: String) async {
        isLoading = true
        error = nil
        do {
            try await APIClient.shared.forgotPassword(email: email)
            self.error = "If an account exists, a reset link was sent."
        } catch {
            self.error = "Could not send reset email. Try again."
        }
        isLoading = false
    }

    func logout() {
        Task { await APIClient.shared.logout() }
        token = nil
        email = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: emailKey)
        AppState.clearWidgetData()
    }

    func handleAuthError() {
        logout()
    }
}

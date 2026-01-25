import Foundation

final class NotificationStateManager {
    static let shared = NotificationStateManager()
    
    private let defaults = UserDefaults.standard
    private let key = "notificationStates"
    
    private init() {}
    
    func setNotificationEnabled(_ enabled: Bool, for cityName: String) {
        var states = getAll()
        states[cityName] = enabled
        defaults.set(states, forKey: key)
    }
    
    func isNotificationEnabled(for cityName: String) -> Bool {
        let states = getAll()
        return states[cityName] ?? false
    }
    
    func removeState(for cityName: String) {
        var states = getAll()
        states.removeValue(forKey: cityName)
        defaults.set(states, forKey: key)
    }
    
    private func getAll() -> [String: Bool] {
        return defaults.dictionary(forKey: key) as? [String: Bool] ?? [:]
    }
}

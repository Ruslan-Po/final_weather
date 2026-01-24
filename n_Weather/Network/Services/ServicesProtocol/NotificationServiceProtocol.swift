import Foundation

protocol NotificationServiceProtocol {
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func scheduleWeatherNotification(
        for city: String,
        temperature: Int,
        description: String,
        frequency: NotificationFrequency
    )
    func cancelWeatherNotification(for city: String)
    func cancelAllNotifications()
}

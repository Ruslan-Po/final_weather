import UserNotifications

enum NotificationFrequency {
    case once(date: Date)
    case daily(hour: Int, minute: Int)
}

final class NotificationService: NotificationServiceProtocol {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleWeatherNotification(
        for city: String,
        temperature: Int,
        description: String,
        frequency: NotificationFrequency
    ) {
        let content = UNMutableNotificationContent()
        content.title = "\(city)"
        content.body = "\(temperature)°C, \(description)"
        content.sound = .default
        content.userInfo = [
            "type": "weather",
            "cityName": city,
            "temperature": temperature
        ]
        
        let trigger: UNCalendarNotificationTrigger
        
        switch frequency {
        case .once(let date):
            trigger = createOnceTrigger(for: date)
            
        case .daily(let hour, let minute):
            trigger = createDailyTrigger(hour: hour, minute: minute)
        }
        
        let identifier = "weather-\(city)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule weather notification: \(error)")
            } else {
                self.logScheduledNotification(city: city, frequency: frequency)
            }
        }
    }
    
    func cancelWeatherNotification(for city: String) {
        let identifier = "weather-\(city)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled notification for \(city)")
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("All notifications cancelled")
    }
    
    private func createOnceTrigger(for date: Date) -> UNCalendarNotificationTrigger {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        return UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
    }
    
    private func createDailyTrigger(hour: Int, minute: Int) -> UNCalendarNotificationTrigger {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        return UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
    }
    
    private func logScheduledNotification(city: String, frequency: NotificationFrequency) {
        switch frequency {
        case .once(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            print("Scheduled ONE-TIME notification for \(city) at \(formatter.string(from: date))")
            
        case .daily(let hour, let minute):
            print("Scheduled DAILY notification for \(city) at \(hour):\(String(format: "%02d", minute))")
        }
    }
}

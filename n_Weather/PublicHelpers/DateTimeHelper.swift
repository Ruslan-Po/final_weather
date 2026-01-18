import Foundation

struct DateTimeHelper {

    private init() {}

    static let hoursFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    
    static let updateDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()

    static func formatTime(from unixTimestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
        return hoursFormatter.string(from: date)
    }

    static func formatTime(from date: Date) -> String {
        return hoursFormatter.string(from: date)
    }

    static func formatDate(from unixTimestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimestamp))
        return dateFormatter.string(from: date).capitalized
    }

    static func formatDate(from date: Date) -> String {
        return dateFormatter.string(from: date).capitalized
    }
    
    static func updateDateFormater(from date: Date) -> String {
        return updateDateFormatter.string(from: date)
    }
}

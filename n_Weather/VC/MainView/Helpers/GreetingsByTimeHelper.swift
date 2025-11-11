import Foundation

struct Greetings {
    static var setGreetingByTime: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<16:
            return "Good Afternoon"
        case 16..<20:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
}

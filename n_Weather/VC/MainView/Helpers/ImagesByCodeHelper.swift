
struct ImagesByCodeHelper {
    static func getImageNameByCode (code: Int) -> String {
        switch code {
        case 200...232:
           return "storm"
        case 300...531:
            return "rain"
        case 600...622:
            return "snow"
        case 701...781:
            return "fog"
        case 800:
            return "clearsky"
        case 801...804:
            return "cloud"
        default:
            return "uncknow"
        }
    }
}

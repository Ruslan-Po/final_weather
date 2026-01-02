import Foundation

struct WeatherModel: Decodable, Sendable {
    let cod: String
    let list: [Forecast]
    let city: City
}

struct City: Decodable, Sendable {
    let name: String
    let coord: Coordinates
    let sunrise: Int
    let sunset: Int
}

struct Coordinates: Decodable, Sendable {
    let lon: Double
    let lat: Double
}

struct Forecast: Decodable, Sendable {
    let datetime: Int
    let date: String
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let visibility: Int

    enum CodingKeys: String, CodingKey {
        case datetime = "dt"
        case date = "dt_txt"
        case main
        case weather
        case wind
        case visibility
    }
}

struct Main: Decodable, Sendable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let pressure: Int
    let feelsLike: Double
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case humidity
        case feelsLike = "feels_like"
        case pressure
    }
}

struct Weather: Decodable, Sendable {
    let main: String
    let description: String
    let id: Int
}

struct Wind: Decodable, Sendable {
    let speed: Double
    let deg: Int
    let gust: Double
}


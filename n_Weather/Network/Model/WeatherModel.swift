// Models.swift
import Foundation

struct WeatherModel: Decodable, Sendable {
    let cod: String
    let list: [Forecast]
    let city: City
    
    init(cod: String, list: [Forecast], city: City) {
        self.cod = cod
        self.list = list
        self.city = city
    }
}

struct City: Decodable, Sendable {
    let name: String
    let coord: Coordinates
    let sunrise: Int
    let sunset: Int
    
    init(name: String, coord: Coordinates, sunrise: Int, sunset: Int) {
            self.name = name
            self.coord = coord
            self.sunrise = sunrise
            self.sunset = sunset
        }
}

struct Coordinates: Decodable, Sendable {
    let lon: Double
    let lat: Double
    
    init(lon: Double, lat: Double) {
           self.lon = lon
           self.lat = lat
       }
}

struct Forecast: Decodable, Sendable {
    let dt: Int
    let date: String
    let main: Main
    let weather: [Weather]
    
    enum CodingKeys: String, CodingKey {
        case dt
        case date = "dt_txt"
        case main
        case weather
    }
    
    init(dt: Int, date: String, main: Main, weather: [Weather]){
        self.dt = dt
        self.date = date
        self.main = main
        self.weather = weather
    }
}

struct Main: Decodable, Sendable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let feelsLike: Double
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case humidity
        case feelsLike = "feels_like"
    }
    
    init ( temp: Double,
           tempMin: Double,
           tempMax: Double,
           humidity: Int,
           feelsLike: Double)
    {
        self.temp = temp
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.humidity = humidity
        self.feelsLike = feelsLike
    }
}

struct Weather: Decodable, Sendable {
    let main: String
    let description: String
    let id: Int
    
    init(main: String,description: String,id: Int) {
        self.main = main
        self.description = description
        self.id = id
    }
}

import Foundation

protocol WeatherClientProtocol {
    func fetch(lon: Double, lat: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void)
}

final class WeatherClientImpl: WeatherClientProtocol {
    private let service = WeatherService()
    func fetch(lon: Double, lat: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        service.fetchWeatherData(longitude: lon, latitude: lat, completion: completion)
    }
}

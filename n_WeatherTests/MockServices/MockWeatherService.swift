import Foundation
@testable import n_Weather

class MockWeatherService: WeatherServiceProtocol {
    var weather: WeatherModel?
    var shouldReturnError = false

    func fetchWeatherData(longitude: Double,
                          latitude: Double,
                          completion: @escaping (Result<n_Weather.WeatherModel, any Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "Test", code: 1)))
        } else if let weather = self.weather {
            completion(.success(weather))
        }
    }
}

import Foundation
@testable import n_Weather

final class MockWeatherClient: WeatherClientProtocol {

    var shouldReturnError = false
    var weatherToReturn: WeatherModel?
    var errorToReturn: Error = NSError(domain: "TestError", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Test error"
    ])

    var fetchWasCalled = false
    var fetchCallCount = 0
    var lastCalledWithLon: Double?
    var lastCalledWithLat: Double?

    func fetch(lon: Double, lat: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        fetchWasCalled = true
        fetchCallCount += 1
        lastCalledWithLon = lon
        lastCalledWithLat = lat

        if shouldReturnError {
            completion(.failure(errorToReturn))
        } else if let weather = weatherToReturn {
            completion(.success(weather))
        }
    }

    func reset() {
        fetchWasCalled = false
        fetchCallCount = 0
        lastCalledWithLon = nil
        lastCalledWithLat = nil
        shouldReturnError = false
        weatherToReturn = nil
    }
}

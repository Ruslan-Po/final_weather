import XCTest
@testable import n_Weather


class MockWeatherRepository: WeatherRepositoryProtocol{
    var currentWeather: WeatherModel?
    var resultToReturn: Result<WeatherModel, any Error>?
    
    var fetchWasCalled = false
    var lastLon: Double?
    var lastLat: Double?
    var lastForceRefresh: Bool?
    
    func fetchCurrentWeather(lon: Double, lat: Double, forceRefresh: Bool, completion: @escaping (Result<WeatherModel, any Error>) -> Void) {
        
        fetchWasCalled = true
        lastLon = lon
        lastLat = lat
        lastForceRefresh = forceRefresh
        
        if let resultToReturn = resultToReturn{
            completion(resultToReturn)
        }
    }
    
    
}

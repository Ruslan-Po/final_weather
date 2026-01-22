import Foundation
@testable import n_Weather

class MockDetailedView: DetailedViewControllerProtocol {
    var receivedWeather: WeatherModel?
    var receivedError: Error?
    var receivedCachedWeather: CachedWeather?
    
    
    func getWeatherDetail(_ detailedWeather: WeatherModel) {
        receivedWeather = detailedWeather
    }
    
    func getWeatherDetailFromCache(_ cachedWeather: CachedWeather) {
        receivedCachedWeather = cachedWeather
    }
    
    func displayError(_ error: any Error) {
        receivedError = error
    }
}

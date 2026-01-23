import Foundation
@testable import n_Weather

final class MockForecastView: ForecastViewControllerProtocol {

    var receivedWeather: [Forecast] = []
    var receivedError: Error?
    
    var getWeatherWasCalled = false
    var displayErrorWasCalled = false
    
 
    func getForecast(_ forecast: [Forecast]) {
        getWeatherWasCalled = true
        receivedWeather = forecast
    }
    
    func displayError(_ error: Error) {
        displayErrorWasCalled = true
        receivedError = error
    }
}

import Foundation
@testable import n_Weather

final class MockForecastView: ForecastViewControllerProtocol {
    
    var getForecastWasCalled = false
    var getForecastCallCount = 0
    var displayErrorWasCalled = false
    var displayErrorCallCount = 0
    
    
    var receivedForecasts: [Forecast]?
    var displayedError: Error?
    var allReceivedForecasts: [[Forecast]] = []
    var allDisplayedErrors: [Error] = []
    
    func getForecast(_ forecasts: [Forecast]) {
        getForecastWasCalled = true
        getForecastCallCount += 1
        receivedForecasts = forecasts
        allReceivedForecasts.append(forecasts)
    }
    
    func displayError(_ error: Error) {
        displayErrorWasCalled = true
        displayErrorCallCount += 1
        displayedError = error
        allDisplayedErrors.append(error)
    }
    
    func reset() {
        getForecastWasCalled = false
        getForecastCallCount = 0
        displayErrorWasCalled = false
        displayErrorCallCount = 0
        receivedForecasts = nil
        displayedError = nil
        allReceivedForecasts.removeAll()
        allDisplayedErrors.removeAll()
    }
}


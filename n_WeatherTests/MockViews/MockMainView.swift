import Foundation
@testable import n_Weather

final class MockMainView: MainViewControllerProtocol {
    var displayWeatherWasCalled = false
    var displayWeatherCallCount = 0
    var displayErrorWasCalled = false
    var displayErrorCallCount = 0

    var displayedWeatherData: MainViewModel?
    var displayedError: Error?
    var allDisplayedWeatherData: [MainViewModel] = []
    var allDisplayedErrors: [Error] = []

    func displayWeather(data: MainViewModel) {
        displayWeatherWasCalled = true
        displayWeatherCallCount += 1
        displayedWeatherData = data
        allDisplayedWeatherData.append(data)
    }

    func displayError(error: Error) {
        displayErrorWasCalled = true
        displayErrorCallCount += 1
        displayedError = error
        allDisplayedErrors.append(error)
    }

    func reset() {
        displayWeatherWasCalled = false
        displayWeatherCallCount = 0
        displayErrorWasCalled = false
        displayErrorCallCount = 0
        displayedWeatherData = nil
        displayedError = nil
        allDisplayedWeatherData.removeAll()
        allDisplayedErrors.removeAll()
    }
}

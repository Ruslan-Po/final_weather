import Foundation
@testable import n_Weather

final class MockMainView: MainViewControllerProtocol {

    
    var displayWeatherWasCalled = false
    var displayErrorWasCalled = false
    
    var displayCitySearchResultWasCalled = false

    var displayedWeatherData: MainViewModel?
    var displayedError: Error?
    var allDisplayedWeatherData: [MainViewModel] = []
    var allDisplayedErrors: [Error] = []

    func displayWeather(data: MainViewModel) {
        displayWeatherWasCalled = true
        displayedWeatherData = data
        allDisplayedWeatherData.append(data)
    }

    func displayError(error: Error) {
        displayErrorWasCalled = true
        displayedError = error
        allDisplayedErrors.append(error)
    }

    func reset() {
        displayWeatherWasCalled = false
        displayErrorWasCalled = false
        displayedWeatherData = nil
        displayCitySearchResultWasCalled = false
        displayedError = nil
        allDisplayedWeatherData.removeAll()
        allDisplayedErrors.removeAll()
    }
    
    func displayCitySearchResults(_ cities: [String]) {
        displayCitySearchResultWasCalled = true
    }
    
    func updateFavoriteStatus() {
        //
    }
}

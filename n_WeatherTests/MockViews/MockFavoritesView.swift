@testable import n_Weather

class MockFavoritesView: FavoritesViewControllerProtocol {
    var getWeatherWasCalled = false
    var showErrorWasCalled = false
    var receivedError: Error?
    
    func getWeather() {
        getWeatherWasCalled = true
    }
    
    func showError(_ error: any Error) {
        showErrorWasCalled = true
        receivedError = error
    }
}

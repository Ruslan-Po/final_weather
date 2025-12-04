import XCTest
@testable import n_Weather

final class MainViewPresenterTests: XCTestCase {

    var sut: MainViewPresenter!

    var mockView: MockMainView!
    var mockClient: MockWeatherClient!
    var mockLocationService: MockLocationService!
    var mockLocationStorage: MockLocationStorage!

    override func setUp() {
        super.setUp()

        mockView = MockMainView()
        mockClient = MockWeatherClient()
        mockLocationService = MockLocationService()
        mockLocationStorage = MockLocationStorage()

        sut = MainViewPresenter(
            view: mockView,
            locationService: mockLocationService,
            client: mockClient,
            locationStorage: mockLocationStorage
        )

        DateTimeHelper.hoursFormatter.timeZone = TimeZone(identifier: "UTC")
        DateTimeHelper.dateFormatter.timeZone = TimeZone(identifier: "UTC")
        DateTimeHelper.dateFormatter.locale = Locale(identifier: "en_US")
    }

    override func tearDown() {
        sut = nil
        mockView = nil
        mockClient = nil
        mockLocationService = nil
        mockLocationStorage = nil
        super.tearDown()
    }

    func test_createViewModel_withValidWeather_returnsCorrectViewModel() {
        // ARRANGE
        let weather = Weather.mock(main: "Clear", description: "clear sky", id: 800)
        let main = Main.mock(temp: 25.5, tempMin: 20.0, tempMax: 28.0, humidity: 60, feelsLike: 24.0)
        let forecast = Forecast.mock(dt: 1704067200, main: main, weather: [weather])
        let city = City.mock(name: "Moscow", sunrise: 1704081600, sunset: 1704117600)
        let weatherModel = WeatherModel.mock(list: [forecast], city: city)

        // ACT
        let viewModel = sut.createViewModel(from: weatherModel)

        // ASSERT
        XCTAssertEqual(viewModel.cityName, "Moscow", "City name should match")
        XCTAssertEqual(viewModel.currentTemp, "25.5°C", "Temperature should be formatted correctly")
        XCTAssertEqual(viewModel.weatherImage, "clearsky", "Weather code 800 should map to clearsky")
        XCTAssertFalse(viewModel.sunrise.isEmpty, "Sunrise should not be empty")
        XCTAssertFalse(viewModel.sunset.isEmpty, "Sunset should not be empty")
        XCTAssertFalse(viewModel.greeting.isEmpty, "Greeting should not be empty")
        XCTAssertFalse(viewModel.currentTime.isEmpty, "Current time should not be empty")
        XCTAssertFalse(viewModel.currentDate.isEmpty, "Current date should not be empty")
    }

    func test_createViewModel_withRainyWeather_returnsRainImage() {
        // ARRANGE
        let weather = Weather.mock(main: "Rain", id: 500)
        let forecast = Forecast.mock(weather: [weather])
        let weatherModel = WeatherModel.mock(list: [forecast])

        // ACT
        let viewModel = sut.createViewModel(from: weatherModel)

        // ASSERT
        XCTAssertEqual(viewModel.weatherImage, "rain", "Weather code 500 should map to rain")
    }

    func test_createViewModel_withEmptyList_returnsEmptyViewModel() {
        // ARRANGE
        let weatherModel = WeatherModel.mock(list: [])

        // ACT
        let viewModel = sut.createViewModel(from: weatherModel)

        // ASSERT
        XCTAssertEqual(viewModel.cityName, "")
        XCTAssertEqual(viewModel.currentTemp, "")
        XCTAssertEqual(viewModel.weatherImage, "")
    }

    func test_createEmptyViewModel_returnsViewModelWithEmptyFields() {
        // ACT
        let viewModel = sut.createEmptyViewModel()

        // ASSERT
        XCTAssertEqual(viewModel.cityName, "")
        XCTAssertEqual(viewModel.currentTemp, "")
        XCTAssertEqual(viewModel.weatherImage, "")
        XCTAssertEqual(viewModel.sunrise, "")
        XCTAssertEqual(viewModel.sunset, "")
        XCTAssertEqual(viewModel.greeting, "")
        XCTAssertEqual(viewModel.currentTime, "")
        XCTAssertEqual(viewModel.currentDate, "")
    }

    func test_fetchWeatherByCoordinates_onSuccess_callsViewDisplayWeather() {
        // ARRANGE
        let lon = 37.6173
        let lat = 55.7558
        let mockWeather = WeatherModel.mock()
        mockClient.weatherToReturn = mockWeather

        let expectation = expectation(description: "Weather displayed")

        // ACT
        sut.fetchWeatherByCoordinates(lon: lon, lat: lat)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        // ASSERT
        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockClient.fetchWasCalled, "Client fetch should be called")
        XCTAssertEqual(mockClient.lastCalledWithLon, lon)
        XCTAssertEqual(mockClient.lastCalledWithLat, lat)
        XCTAssertTrue(mockView.displayWeatherWasCalled, "View should display weather")
        XCTAssertNotNil(mockView.displayedWeatherData)
        XCTAssertFalse(mockView.displayErrorWasCalled, "Error should not be called on success")
    }

    func test_fetchWeatherByCoordinates_onSuccess_savesLocation() {
        // ARRANGE
        let lon = 37.6173
        let lat = 55.7558
        let cityName = "Moscow"
        let city = City.mock(name: cityName)
        let mockWeather = WeatherModel.mock(city: city)
        mockClient.weatherToReturn = mockWeather

        let expectation = expectation(description: "Location saved")

        // ACT
        sut.fetchWeatherByCoordinates(lon: lon, lat: lat)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        // ASSERT
        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockLocationStorage.saveWasCalled, "Should save location")
        XCTAssertEqual(mockLocationStorage.lastSavedLocation?.lon, lon)
        XCTAssertEqual(mockLocationStorage.lastSavedLocation?.lat, lat)
        XCTAssertEqual(mockLocationStorage.lastSavedLocation?.cityName, cityName)
    }

    func test_fetchWeatherByCoordinates_onError_callsViewDisplayError() {
        // ARRANGE
        mockClient.shouldReturnError = true
        mockClient.errorToReturn = NSError.testError(description: "Network error")

        let expectation = expectation(description: "Error displayed")

        // ACT
        sut.fetchWeatherByCoordinates(lon: 0, lat: 0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        // ASSERT
        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockClient.fetchWasCalled, "Client should be called even on error")
        XCTAssertTrue(mockView.displayErrorWasCalled, "View should display error")
        XCTAssertNotNil(mockView.displayedError)
        XCTAssertFalse(mockView.displayWeatherWasCalled, "Weather should not be displayed on error")
    }

    func test_fetchWeatherForCurrentLocation_onSuccess_fetchesAndDisplaysWeather() {
        // ARRANGE
        mockLocationService.setMockCoordinates(latitude: 55.7558, longitude: 37.6173)

        let mockWeather = WeatherModel.mock()
        mockClient.weatherToReturn = mockWeather

        let expectation = expectation(description: "Current location weather fetched")

        // ACT
        sut.fetchWeatherForCurrentLocation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // ASSERT
        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockLocationService.getCurrentLocationWasCalled, "Should request current location")
        XCTAssertTrue(mockClient.fetchWasCalled, "Should fetch weather")
        XCTAssertEqual(mockClient.lastCalledWithLon, 37.6173)
        XCTAssertEqual(mockClient.lastCalledWithLat, 55.7558)
        XCTAssertTrue(mockView.displayWeatherWasCalled, "Should display weather")
        XCTAssertTrue(mockLocationStorage.saveWasCalled, "Should save location")
    }

    func test_fetchWeatherForCurrentLocation_onLocationError_displaysError() {
        // ARRANGE
        mockLocationService.setMockError(.permissionDenied)

        let expectation = expectation(description: "Location error handled")

        // ACT
        sut.fetchWeatherForCurrentLocation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        // ASSERT
        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockLocationService.getCurrentLocationWasCalled)
        XCTAssertTrue(mockView.displayErrorWasCalled, "Should display location error")
        XCTAssertFalse(mockClient.fetchWasCalled, "Should not fetch weather on location error")
    }

    func test_searchWeather_withValidCity_fetchesAndDisplaysWeather() {
        // ARRANGE
        let cityName = "London"
        mockLocationService.setMockCoordinates(latitude: 51.5074, longitude: -0.1278)

        let mockWeather = WeatherModel.mock(city: City.mock(name: cityName))
        mockClient.weatherToReturn = mockWeather

        let expectation = expectation(description: "City weather fetched")

        // ACT
        sut.searchWeather(for: cityName)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // ASSERT
        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockLocationService.getCoordinatesWasCalled, "Should get coordinates for city")
        XCTAssertEqual(mockLocationService.lastSearchedCityName, cityName)
        XCTAssertTrue(mockClient.fetchWasCalled, "Should fetch weather")
        XCTAssertTrue(mockView.displayWeatherWasCalled, "Should display weather")
        XCTAssertTrue(mockLocationStorage.saveWasCalled, "Should save location")
        XCTAssertEqual(mockLocationStorage.lastSavedLocation?.cityName, cityName)
    }

    func test_searchWeather_withInvalidCity_displaysError() {
        // ARRANGE
        let cityName = "NonExistentCity"
        mockLocationService.setMockError(.cityNotFound)

        let expectation = expectation(description: "Search error handled")

        // ACT
        sut.searchWeather(for: cityName)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        // ASSERT
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(mockLocationService.getCoordinatesWasCalled)
        XCTAssertTrue(mockView.displayErrorWasCalled, "Should display search error")
        XCTAssertFalse(mockClient.fetchWasCalled, "Should not fetch weather on search error")
    }

    func test_start_withSavedLocation_fetchesWeatherForSavedLocation() {
        // ARRANGE
        let savedLocation = LastLocation(
            lon: 37.6173,
            lat: 55.7558,
            cityName: "Moscow",
            updatedAt: Date()
        )
        mockLocationStorage.setSavedLocation(savedLocation)

        let mockWeather = WeatherModel.mock()
        mockClient.weatherToReturn = mockWeather

        let expectation = expectation(description: "Saved location weather fetched")

        // ACT
        sut.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        // ASSERT
        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockLocationStorage.getWasCalled, "Should check for saved location")
        XCTAssertTrue(mockClient.fetchWasCalled, "Should fetch weather")
        XCTAssertEqual(mockClient.lastCalledWithLon, savedLocation.lon)
        XCTAssertEqual(mockClient.lastCalledWithLat, savedLocation.lat)
        XCTAssertFalse(mockLocationService.getCurrentLocationWasCalled,
                      "Should not request current location when saved location exists")
    }

    func test_start_withoutSavedLocation_fetchesCurrentLocation() {
        // ARRANGE

        mockLocationService.setMockCoordinates(latitude: 55.7558, longitude: 37.6173)

        let mockWeather = WeatherModel.mock()
        mockClient.weatherToReturn = mockWeather

        let expectation = expectation(description: "Current location fetched")

        // ACT
        sut.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // ASSERT
        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockLocationStorage.getWasCalled, "Should check for saved location")
        XCTAssertTrue(mockLocationService.getCurrentLocationWasCalled,
                     "Should request current location when no saved location")
        XCTAssertTrue(mockClient.fetchWasCalled, "Should fetch weather")
    }

    func test_fetchWeatherByCoordinates_multipleCalls_eachCallSavesLocation() {
        // ARRANGE
        let mockWeather = WeatherModel.mock()
        mockClient.weatherToReturn = mockWeather

        let expectation = expectation(description: "Multiple fetches")
        expectation.expectedFulfillmentCount = 2

        // ACT
        sut.fetchWeatherByCoordinates(lon: 10, lat: 20)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        sut.fetchWeatherByCoordinates(lon: 30, lat: 40)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }

        // ASSERT
        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(mockClient.fetchCallCount, 2, "Should call fetch twice")
        XCTAssertEqual(mockLocationStorage.saveCallCount, 2, "Should save location twice")
        XCTAssertEqual(mockView.displayWeatherCallCount, 2, "Should display weather twice")
    }
}

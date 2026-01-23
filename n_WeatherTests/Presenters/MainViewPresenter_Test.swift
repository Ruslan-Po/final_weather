import XCTest
@testable import n_Weather

final class MainViewPresenterTests: XCTestCase {
    
    var sut: MainViewPresenter!
    var mockView: MockMainView!
    var mockLocationService: MockLocationService!
    var mockRepository: MockWeatherRepository!
    var mockCitySearchService: MockCitySearchService!
    var mockLocationStorage: MockLocationStorage!
    var mockFavoritesStorage: MockFavoritesStorage!
    
    override func setUp() {
        super.setUp()
        
        mockView = MockMainView()
        mockLocationService = MockLocationService()
        mockRepository = MockWeatherRepository()
        mockCitySearchService = MockCitySearchService()
        mockLocationStorage = MockLocationStorage()
        mockFavoritesStorage = MockFavoritesStorage()
        
        sut = MainViewPresenter(
            view: mockView,
            locationService: mockLocationService,
            repository: mockRepository,
            citySearchService: mockCitySearchService,
            locationStorage: mockLocationStorage,
            favoritesStorage: mockFavoritesStorage
        )
        
        DateTimeHelper.hoursFormatter.timeZone = TimeZone(identifier: "UTC")
        DateTimeHelper.dateFormatter.timeZone = TimeZone(identifier: "UTC")
        DateTimeHelper.dateFormatter.locale = Locale(identifier: "en_US")
    }
    
    override func tearDown() {
        sut = nil
        mockView = nil
        mockRepository = nil
        mockLocationService = nil
        mockLocationStorage = nil
        mockCitySearchService = nil
        mockFavoritesStorage = nil
        super.tearDown()
    }
    
    func test_MainViewPresenter_createViewModel_returnsCorrectViewModel() {
        let weather = Weather.mock(main: "Clear", description: "clear sky", id: 800)
        let main = Main.mock(temp: 25.5, tempMin: 20.0, tempMax: 28.0, humidity: 60, feelsLike: 24.0)
        let forecast = Forecast.mock(datetime: 1704067200, main: main, weather: [weather])
        let city = City.mock(name: "Moscow", sunrise: 1704081600, sunset: 1704117600)
        let weatherModel = WeatherModel.mock(list: [forecast], city: city)
        
        let viewModel = sut.createViewModel(from: weatherModel)
        
        XCTAssertEqual(viewModel.cityName, "Moscow")
        XCTAssertEqual(viewModel.currentTemp, "26 °C")
        XCTAssertEqual(viewModel.weatherImage, "clearsky")
        XCTAssertFalse(viewModel.sunrise.isEmpty)
        XCTAssertFalse(viewModel.sunset.isEmpty)
        XCTAssertFalse(viewModel.greeting.isEmpty)
    }
    
    func test_MainViewPresenter_createViewModel_withEmptyList_returnsEmptyViewModel() {
        let weatherModel = WeatherModel.mock(list: [])
        
        let viewModel = sut.createViewModel(from: weatherModel)
        
        XCTAssertEqual(viewModel.cityName, "")
        XCTAssertEqual(viewModel.currentTemp, "")
        XCTAssertEqual(viewModel.weatherImage, "")
    }
    
    func test_MainViewPresenter_createEmptyViewModel_returnsEmptyFields() {
        let viewModel = sut.createEmptyViewModel()
        
        XCTAssertEqual(viewModel.cityName, "")
        XCTAssertEqual(viewModel.currentTemp, "")
        XCTAssertEqual(viewModel.weatherImage, "")
        XCTAssertEqual(viewModel.sunrise, "")
        XCTAssertEqual(viewModel.sunset, "")
    }
    
    func test_MainViewPresenter_searchCity_callsCitySearchService() {
        sut.searchCity(query: "Paris")
        
        XCTAssertTrue(mockCitySearchService.searchWasCalled)
        XCTAssertEqual(mockCitySearchService.lastSearchQuery, "Paris")
    }
    
    func test_MainViewPresenter_fetchWeatherByCoordinates_callsRepository() {
        mockRepository.resultToReturn = .success(WeatherModel.mock())
        
        sut.fetchWeatherByCoordinates(lon: 37.6173, lat: 55.7558)
        
        XCTAssertTrue(mockRepository.fetchWasCalled)
        XCTAssertEqual(mockRepository.lastLon, 37.6173)
        XCTAssertEqual(mockRepository.lastLat, 55.7558)
        XCTAssertEqual(mockRepository.lastForceRefresh, false)
    }
    
    func test_MainViewPresenter_toggleCityFavoriteStatus_returnsTrueForFavorite() {
        mockFavoritesStorage.isFavoriteResult = true
        
        let result = sut.toggleCityFavoriteStatus()
        
        XCTAssertTrue(result)
    }
    
    func test_MainViewPresenter_toggleCityFavoriteStatus_returnsFalseForNonFavorite() {
        mockFavoritesStorage.isFavoriteResult = false
        
        let result = sut.toggleCityFavoriteStatus()
        
        XCTAssertFalse(result)
    }
    
    func test_MainViewPresenter_removeCityFromFavorites_callsFavoritesStorage() {
        let savedLocation = LastLocation(lon: 37.6173, lat: 55.7558, cityName: "Moscow", updatedAt: Date())
        mockLocationStorage.locationToReturn = savedLocation
        
        sut.removeCityFromFavorites()
        
        XCTAssertTrue(mockFavoritesStorage.deleteFavoriteCityWasCalled)
        XCTAssertEqual(mockFavoritesStorage.lastDeletedCityName, "Moscow")
    }
}

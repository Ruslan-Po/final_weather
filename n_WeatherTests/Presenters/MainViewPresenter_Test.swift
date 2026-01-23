import XCTest
@testable import n_Weather

final class MainViewPresenterTests: XCTestCase {

    var sut: MainViewPresenter!

    var mockView: MockMainView!
    var mockClient: MockWeatherClient!
    var mockLocationService: MockLocationService!
    var mockLocationStorage: MockLocationStorage!
    var mockRepository: MockWeatherRepository!
    var mockCitySearchService: MockCitySearchService!
    var mockFavoritesStorage: MockFavoritesStorage!

    override func setUp() {
        super.setUp()

        mockView = MockMainView()
        mockClient = MockWeatherClient()
        mockLocationService = MockLocationService()
        mockLocationStorage = MockLocationStorage()
        mockRepository = MockWeatherRepository()
        mockCitySearchService = MockCitySearchService()
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
        mockClient = nil
        mockLocationService = nil
        mockLocationStorage = nil
        mockRepository = nil
        mockCitySearchService = nil
        mockFavoritesStorage = nil
        super.tearDown()
    }
    func test_fetchWeatherByCoordinates_callsRepository() {

        let lon = 37.6173
        let lat = 55.7558
        mockRepository.resultToReturn = .success(WeatherModel.mock())
        sut.fetchWeatherByCoordinates(lon: lon, lat: lat)

        XCTAssertTrue(mockRepository.fetchWasCalled)
        XCTAssertEqual(mockRepository.lastLon, lon)
        XCTAssertEqual(mockRepository.lastLat, lat)
        XCTAssertEqual(mockRepository.lastForceRefresh, false)
    }
    
    
    func test_MainViewPresenter_createViewModel_callsView() {
        let weatherModel = WeatherModel.mock()
        mockRepository.resultToReturn = .success(weatherModel)
        
        let viewModel = sut.createViewModel(from: weatherModel)
        
        XCTAssertNotNil(viewModel, "View model was created")
        XCTAssertEqual(viewModel.cityName, weatherModel.city.name, "City's is equal")
    }
    
    
}



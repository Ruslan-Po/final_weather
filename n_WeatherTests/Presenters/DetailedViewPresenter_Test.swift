import XCTest
@testable import n_Weather

final class DetailedWeatherTests: XCTestCase {
    var sut: DetailedViewPresenter!
        var mockStorage: MockLocationStorage!
        var mockRepository: MockWeatherRepository!
        var mockView: MockDetailedView!
        
        override func setUp() {
            super.setUp()
            mockStorage = MockLocationStorage()
            mockRepository = MockWeatherRepository()
            mockView = MockDetailedView()
            sut = DetailedViewPresenter(
                view: mockView,
                repository: mockRepository,
                locationStorage: mockStorage)
        }
        
        override func tearDown() {
            sut = nil
            mockStorage = nil
            mockRepository = nil
            mockView = nil
            super.tearDown()
        }
    
    func test_DetailedViewPresenter_getSaveCityName_ReturnCityName() {
        
        let expectedCityName = WeatherModel.mock().city.name
        let savedLocation = LastLocation(
            lon: 54.12,
            lat: 34.32,
            cityName: expectedCityName,
            updatedAt: Date()
        )
        mockStorage.locationToReturn = savedLocation
        
        let result = sut.getSavedCityName()
        
        XCTAssertEqual(result, expectedCityName, "CityNames should be equal")
    }
    func test_DetailedViewPresenter_getSaveCityName_ReturnNil() {
        mockStorage.locationToReturn = nil
        
        let result = sut.getSavedCityName()
        
        XCTAssertNil(result , "Location is nil")
    }
    
    
    func test_DetailedViewPresenter_fetchWeatherByCoordinates_ReturnWeather() {
        let expectedWeather = WeatherModel.mock()
        mockRepository.resultToReturn = .success(expectedWeather)
        
        sut.fetchWeatherByCoordinates(lon: 37.61, lat: 55.75)
        
        XCTAssertTrue(mockRepository.fetchWasCalled, "Fetch must be called")
        XCTAssertEqual(mockRepository.lastLon, 37.61, "Longitude Must Be Equal")
        XCTAssertEqual(mockRepository.lastLat, 55.75, "Latitude Must Be Equal")
        XCTAssertEqual(mockRepository.lastForceRefresh,false, "Must be Nil")
        
        XCTAssertNil(mockView.receivedError, "Error must be Nil")
    }
    
    func test_DetailedViewPresenter_fetchWeatherByCoordinates_ReturnError() {
        let expectedError = NSError(domain: "Test", code: 404, userInfo: nil)
        mockRepository.resultToReturn = .failure(expectedError)
        
        sut.fetchWeatherByCoordinates(lon: 37.61, lat: 55.75)
        
        XCTAssertTrue(mockRepository.fetchWasCalled, "Repository must be called")
        XCTAssertNotNil(mockView.receivedError, "Error must exist")
        XCTAssertNil(mockView.receivedWeather, "Weather must be nil")
    }
    
    
}

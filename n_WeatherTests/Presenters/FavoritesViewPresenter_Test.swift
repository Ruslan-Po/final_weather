import XCTest
@testable import n_Weather

final class FavoritesViewPresenterTests: XCTestCase {
    var sut: FavoritesViewPresenter!
    var mockView: MockFavoritesView!
    var mockDataCoreManager: MockFavoritesStorage!
    var mockRepository: MockWeatherRepository!
    var mockLocationService: MockLocationService!
    
    override func setUp() {
        super.setUp()
        
        mockView = MockFavoritesView()
        mockDataCoreManager = MockFavoritesStorage()
        mockRepository = MockWeatherRepository()
        mockLocationService = MockLocationService()
        
        sut = FavoritesViewPresenter(
            view: mockView,
            dataCoreManager: mockDataCoreManager,
            repository: mockRepository,
            locatonService: mockLocationService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockView = nil
        mockDataCoreManager = nil
        mockRepository = nil
        mockLocationService = nil
        super.tearDown()
    }
    
    func test_FavoriteViewPresenter_loadSavedWeather_callsFetchAllFavorites() {
        mockDataCoreManager.citiesToReturn = []
        
        let result = sut.loadSavedWeather()
        
        XCTAssertTrue(mockDataCoreManager.fetchWasCalled)
        XCTAssertEqual(result.count, 0)
    }
    
    func test_FavoriteViewPresenter_deleteCity_callsDataCoreManager() {
        sut.deleteCity(cityName: "Moscow")
        
        XCTAssertTrue(mockDataCoreManager.deleteFavoriteCityWasCalled)
        XCTAssertEqual(mockDataCoreManager.lastDeletedCityName, "Moscow")
    }
    
    func test_FavoriteViewPresenter_removeAllFavorites_callsFetchAndDelete() {
        mockDataCoreManager.citiesToReturn = []
        
        sut.removeAllFavorites()
        
        XCTAssertTrue(mockDataCoreManager.fetchWasCalled)
    }
    
    func test_FavoriteViewPresenter_refreshAllFavorites_withEmptyList_doesNothing() {
        mockDataCoreManager.citiesToReturn = []
        
        sut.refreshAllFavorites()
        
        XCTAssertFalse(mockLocationService.getCoordinatesWasCalled)
        XCTAssertFalse(mockRepository.fetchWasCalled)
    }
    
    func test_FavoriteViewPresenter_refreshAllFavorites_callsLocationService() {
        mockDataCoreManager.citiesToReturn = []
        mockLocationService.setMockCoordinates(latitude: 48.8566, longitude: 2.3522)
        mockRepository.resultToReturn = .success(WeatherModel.mock())
        
        sut.refreshAllFavorites()
        
        XCTAssertTrue(mockDataCoreManager.fetchWasCalled)
    }
}

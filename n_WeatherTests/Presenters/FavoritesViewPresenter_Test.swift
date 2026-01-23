import XCTest
import CoreData
@testable import n_Weather

final class FavoritesViewPresenterTests: XCTestCase {
    var sut: FavoritesViewPresenter!
    var mockView: MockFavoritesView!
    var mockDataCoreManager: MockFavoritesStorage!
    var mockRepository: MockWeatherRepository!
    var mockLocationService: MockLocationService!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        
        context = CoreDataTestHelper.createInMemoryContext()
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
        context = nil
        super.tearDown()
    }
    
    func test_FavoriteViewPresenter_loadSavedWeather_returnsAllFavorites() {
        let city1 = FavoriteCity.mock(in: context, cityName: "Moscow")
        let city2 = FavoriteCity.mock(in: context, cityName: "London")
        mockDataCoreManager.citiesToReturn = [city1, city2]
        
        let result = sut.loadSavedWeather()
        
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(mockDataCoreManager.fetchWasCalled)
    }
    
    func test_FavoriteViewPresenter_loadSavedWeather_returnsEmptyArray() {
        mockDataCoreManager.citiesToReturn = []
        
        let result = sut.loadSavedWeather()
        
        XCTAssertEqual(result.count, 0)
    }
    
    func test_deleteCity_callsDataCoreManager() {
        let city1 = FavoriteCity.mock(in: context, cityName: "Moscow")
        sut.deleteCity(cityName: city1.cityName)
        
        XCTAssertTrue(mockDataCoreManager.deleteFavoriteCityWasCalled)
        XCTAssertEqual(mockDataCoreManager.lastDeletedCityName, "Moscow")
    }
    
    func test_removeAllFavorites_deletesAllCities() {
        let city1 = FavoriteCity.mock(in: context, cityName: "Moscow")
        let city2 = FavoriteCity.mock(in: context, cityName: "London")
        mockDataCoreManager.citiesToReturn = [city1, city2]
        
        sut.removeAllFavorites()
        
        XCTAssertTrue(mockDataCoreManager.fetchWasCalled)
        XCTAssertTrue(mockDataCoreManager.deleteFavoriteCityWasCalled)
        XCTAssertEqual(mockDataCoreManager.deleteCallCount, 2)
    }
    
    func test_FavoriteViewPresenter_refreshAllFavorites_withEmptyList_doesNothing() {
        mockDataCoreManager.citiesToReturn = []
        
        sut.refreshAllFavorites()
        
        XCTAssertFalse(mockLocationService.getCoordinatesWasCalled)
        XCTAssertFalse(mockRepository.fetchWasCalled)
    }
    
    func test_FavoriteViewPresenter_refreshAllFavorites_updatesDataCoreManager() {
        let city = FavoriteCity.mock(in: context, cityName: "Paris")
        mockDataCoreManager.citiesToReturn = [city]
        mockLocationService.setMockCoordinates(latitude: 48.8566, longitude: 2.3522)
        mockRepository.resultToReturn = .success(WeatherModel.mock())
        
        let expectation = XCTestExpectation(description: "Update called")
        
        sut.refreshAllFavorites()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockDataCoreManager.updateFavoriteWasCalled)
    }
    
    func test_FavoriteViewPresenter_refreshAllFavorites_savesContext() {
        let city = FavoriteCity.mock(in: context, cityName: "Berlin")
        mockDataCoreManager.citiesToReturn = [city]
        mockLocationService.setMockCoordinates(latitude: 52.5200, longitude: 13.4050)
        mockRepository.resultToReturn = .success(WeatherModel.mock())
        
        let expectation = XCTestExpectation(description: "Context saved")
        
        sut.refreshAllFavorites()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.5)
        
        XCTAssertTrue(mockDataCoreManager.saveContextWasCalled)
    }
}

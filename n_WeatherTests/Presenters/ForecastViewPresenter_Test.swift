import XCTest
@testable import n_Weather

final class ForecastViewPresenterTests: XCTestCase {
    var sut: ForecastViewPresenter!
    var mockView: MockForecastView!
    var mockRepository: MockWeatherRepository!
    var mockLocationStorage: MockLocationStorage!

    override func setUp() {
        super.setUp()
        mockView = MockForecastView()
        mockRepository = MockWeatherRepository()
        mockLocationStorage = MockLocationStorage()

        sut = ForecastViewPresenter(
            view: mockView,
            repository: mockRepository,
            locationStorage: mockLocationStorage
        )
    }

    override func tearDown() {
        sut = nil
        mockView = nil
        mockRepository = nil
        mockLocationStorage = nil
        super.tearDown()
    }
    
    func test_ForecastViewPresenter_getSavedCityName_returnCity() {
        let locationToReturn = LastLocation.mock()
        mockLocationStorage.save(locationToReturn)
        
        let result = sut.getSavedCityName()
        
        XCTAssertEqual(locationToReturn.cityName, result)
    }
    
    func test_ForecastViewPresenter_fetchWeatherByCoordinates_callsRepository() {
        sut.fetchWeatherByCoordinates(lon: 10, lat: 20)
        
        XCTAssertTrue(mockRepository.fetchWasCalled)
    }
    
    func test_ForecastViewPresenter_fetchWeatherByCoordinates_savesLocation() {
        
        let lon = 37.6173
        let lat = 55.7558
        let cityName = "Moscow"
        
        let weatherModel = WeatherModel.mock(
            city: City.mock(name: cityName)
        )
        mockRepository.resultToReturn = .success(weatherModel)
        
        sut.fetchWeatherByCoordinates(lon: lon, lat: lat)
        
        XCTAssertTrue(mockLocationStorage.saveCalled, "Location was saved")
        XCTAssertEqual(mockLocationStorage.locationToReturn?.lon, lon)
        XCTAssertEqual(mockLocationStorage.locationToReturn?.lat, lat)
        XCTAssertEqual(mockLocationStorage.locationToReturn?.cityName, cityName)
        XCTAssertNotNil(mockLocationStorage.locationToReturn?.updatedAt, "Must be updated")
    }
        
    func test_ForecastViewPresenter_filter_returnFilteredForecast() {
        let day1 = Date(timeIntervalSince1970: 1704067200)
        let day2 = Date(timeIntervalSince1970: 1704153600)
        let day2_plus3h = Date(timeIntervalSince1970: 1704164400)
        let day3 = Date(timeIntervalSince1970: 1704240000)
        
        let weatherModel = WeatherModel.mock(
            list: [
                Forecast.mock(datetime: Int(day1.timeIntervalSince1970)),
                Forecast.mock(datetime: Int(day2.timeIntervalSince1970)),
                Forecast.mock(datetime: Int(day2_plus3h.timeIntervalSince1970)),
                Forecast.mock(datetime: Int(day3.timeIntervalSince1970))
            ]
        )
        
        let filteredList = sut.filter(weatherModel: weatherModel)
        
        XCTAssertEqual(filteredList.count, 2, "Must be two forecast")
        XCTAssertEqual(filteredList[0].datetime, Int(day2.timeIntervalSince1970), "TimeStamp is equal")
        XCTAssertEqual(filteredList[1].datetime, Int(day3.timeIntervalSince1970), "TimeStamp is equal")
    }
    
    func test_ForecastViewPresenter_filter_returnEmptyList(){
        let weatherModel = WeatherModel.mock(
            list: [
                Forecast.mock(datetime: 1704067200)
            ]
        )
        let filteredList = sut.filter(weatherModel: weatherModel)
            
            XCTAssertEqual(filteredList.count, 0, "Empty after dropFirst()")
    }
    
    func test_fetchWeatherByCoordinates_onFailure_callsDisplayError() {

           let testError = NSError(domain: "TestError", code: 404, userInfo: nil)
           mockRepository.resultToReturn = .failure(testError)
           
           sut.fetchWeatherByCoordinates(lon: 0, lat: 0)
           
           XCTAssertTrue(mockView.displayErrorWasCalled, "View must catch error")
           XCTAssertNotNil(mockView.receivedError, "Error must be not Nil")
       }
}

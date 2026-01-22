//import XCTest
//@testable import n_Weather
//
//final class ForecastViewPresenterTests: XCTestCase {
//    var sut: ForecastViewPresenter!
//    var mockView: MockForecastView!
//    var mockClient: MockWeatherClient!
//    var mockLocationStorage: MockLocationStorage!
//
//    override func setUp() {
//        super.setUp()
//        mockView = MockForecastView()
//        mockClient = MockWeatherClient()
//        mockLocationStorage = MockLocationStorage()
//
//        sut = ForecastViewPresenter(
//            view: mockView,
//            client: mockClient,
//            locationStorage: mockLocationStorage
//        )
//    }
//
//    override func tearDown() {
//        sut = nil
//        mockView = nil
//        mockClient = nil
//        mockLocationStorage = nil
//        super.tearDown()
//    }
//
//    func test_filter_removesTodayAndDuplicateDays() {
//        let today = Date()
//        let calendar = Calendar.current
//
//        let todayTimestamp = Int(today.timeIntervalSince1970)
//        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
//        let tomorrowTimestamp = Int(tomorrow.timeIntervalSince1970)
//        let tomorrowEvening = calendar.date(byAdding: .hour, value: 6, to: tomorrow)!
//        let tomorrowEveningTimestamp = Int(tomorrowEvening.timeIntervalSince1970)
//        let dayAfter = calendar.date(byAdding: .day, value: 2, to: today)!
//        let dayAfterTimestamp = Int(dayAfter.timeIntervalSince1970)
//
//        let forecasts = [
//            Forecast.mock(datetime: todayTimestamp),           // today must be skipped
//            Forecast.mock(datetime: tomorrowTimestamp),        // tommorow must stay
//            Forecast.mock(datetime: tomorrowEveningTimestamp), // tommorow evening (duble or skip)
//            Forecast.mock(datetime: dayAfterTimestamp)         // day after tommorow
//        ]
//
//        let weatherModel = WeatherModel.mock(list: forecasts)
//
//        let filtered = sut.filter(weatherModel: weatherModel)
//
//        XCTAssertEqual(filtered.count, 2, "Should have 2 forecasts (tomorrow and day after)")
//        XCTAssertEqual(filtered[0].datetime, tomorrowTimestamp, "First should be tomorrow")
//        XCTAssertEqual(filtered[1].datetime, dayAfterTimestamp, "Second should be day after tomorrow")
//    }
//
//    func test_getSavedCityName_withSavedLocation_returnsCityName() {
//        let savedLocation = LastLocation(
//            lon: 37.6173,
//            lat: 55.7558,
//            cityName: "Moscow",
//            updatedAt: Date()
//        )
//        mockLocationStorage.setSavedLocation(savedLocation)
//
//        let cityName = sut.getSavedCityName()
//
//        XCTAssertEqual(cityName, "Moscow")
//        XCTAssertTrue(mockLocationStorage.getWasCalled)
//    }
//
//    func test_fetchUsingSavedLocation_withoutSavedLocation_displaysError() {
//        sut.fetchUsingSavedLocation()
//
//        XCTAssertTrue(mockLocationStorage.getWasCalled)
//        XCTAssertTrue(mockView.displayErrorWasCalled)
//        XCTAssertFalse(mockClient.fetchWasCalled, "Should not fetch without saved location")
//    }
//}

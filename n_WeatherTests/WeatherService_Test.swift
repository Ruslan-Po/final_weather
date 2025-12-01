
import XCTest
@testable import n_Weather

final class WeatherService_Tests: XCTestCase {
    var weatherService: WeatherService!
    
    override func setUp() {
        super.setUp()
        weatherService = WeatherService()
    }
    
    override func tearDown() {
        weatherService = nil
        super.tearDown()
    }
    
    func test_WeatherService_createWeatherURL_expectedURL() {
        
        let lon = 37.6173
        let lat = 55.7558
        let key = "test_api_key"
        let url = weatherService.createWeatherURL(lon: lon, lat: lat, key: key)
        XCTAssertNotNil(url, "URL is not correct")
    }
}

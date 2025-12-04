
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
    
    func test_reateWeatherURL_withValidCoordinates_returnCorrectURL() {
        let lon = 37.6173
        let lat = 55.7558
        let key = "test_api_key"
        let url = weatherService.createWeatherURL(lon: lon, lat: lat, key: key)
        
        XCTAssertNotNil(url, "URL is not correct")
        
        guard let unwrappedURL = url else {
            XCTFail( "URL is nil")
            return }
        
        XCTAssertEqual(unwrappedURL.scheme, "https", "Scheme should be HTTPS")
        XCTAssertEqual(unwrappedURL.host, "api.openweathermap.org", "Incorrect host")
        XCTAssertEqual(unwrappedURL.path, "/data/2.5/forecast", "incorrect path")
        
        let components = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems
        
        XCTAssertNotNil(queryItems, "Query items isn't exist")
        XCTAssertEqual(queryItems?.count, 4, "Query items should contaiins 4 params")
        
        XCTAssertTrue(queryItems?.contains(URLQueryItem(name: "lon", value: "37.6173")) ?? false)
        XCTAssertTrue(queryItems?.contains(URLQueryItem(name: "lat", value: "55.7558")) ??  false)
        XCTAssertTrue(queryItems?.contains(URLQueryItem(name: "appid", value: "test_api_key")) ?? false)
        XCTAssertTrue(queryItems?.contains(URLQueryItem(name: "units", value: "metric")) ?? false)
        
    }
}



import Foundation

struct AppContainer {
    let storage: LocationStorageProtocol = LocationStorageUD()
    let client: WeatherClientProtocol = WeatherClientImpl()
    let locationService: LocationServiceProtocol = LocationService()
    let citySearchService: CitySearchServiceProtocol = CitySearchService()
}

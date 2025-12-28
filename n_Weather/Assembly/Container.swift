import Foundation

final class AppContainer {
    let storage: LocationStorageProtocol = LocationStorageUD()
    private let client: WeatherClientProtocol = WeatherClientImpl()
    let locationService: LocationServiceProtocol = LocationService()
    let citySearchService: CitySearchServiceProtocol = CitySearchService()
    
    lazy var weatherRepository: WeatherRepositoryProtocol = {
            WeatherRepository(client: client)
        }()
}

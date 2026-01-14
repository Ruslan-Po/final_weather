import Foundation

final class AppContainer {
    let storage: LocationStorageProtocol = LocationStorageUD()
    private let client: WeatherClientProtocol = WeatherClientImpl()
    let locationService: LocationServiceProtocol = LocationService()
    let citySearchService: CitySearchServiceProtocol = CitySearchService()
    let favoritesStorage: FavoritesStorageProtocol = DataCoreStorageManager.shared
     
    
    lazy var weatherRepository: WeatherRepositoryProtocol = {
            WeatherRepository(client: client)
        }()
}

import Foundation

final class AppContainer {
    let storage: LocationStorageProtocol = LocationStorageUD()
    let client: WeatherClientProtocol = WeatherClientImpl()
    let locationService: LocationServiceProtocol = LocationService() // твоя реализация
}

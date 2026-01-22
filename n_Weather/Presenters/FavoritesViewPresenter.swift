import UIKit
import Foundation
import CoreData
internal import _LocationEssentials


class FavoritesViewPresenter: FavoritesViewPresenterProtocol {

    weak var view: FavoritesViewControllerProtocol?
    let dataCoreManager: FavoritesStorageProtocol
    private let repository: WeatherRepositoryProtocol
    private let locationService: LocationServiceProtocol
    
    init(view: FavoritesViewControllerProtocol?,
         dataCoreManager: FavoritesStorageProtocol,
         repository: WeatherRepositoryProtocol,
         locatonService: LocationServiceProtocol) {
        self.view = view
        self.dataCoreManager = dataCoreManager
        self.repository = repository
        self.locationService = locatonService
    }

    func loadSavedWeather() -> [FavoriteCity] {
        let cities = dataCoreManager.fetchAllFavorites()
        return cities
    }
    
    
    func createDetailViewModel(from cached: CachedWeather) -> DetailViewModel {
        return DetailViewModel(
            windSpeed: "Speed: \(cached.windSpeed) m/s",
            windDeg: "Degrees: \(cached.windDeg)",
            windGust: "Gust: \(cached.windGust) m/s",
            feelsLike: "Feels like: \(cached.feelsLike) С°",
            tempMax: "Max Temp: \(cached.tempMax) С°",
            tempMin: "Min Temp: \(cached.tempMin) С°",
            humidity: "Humidity: \(cached.humidity) %",
            pressure: "Pressure: \(cached.pressure) mb",
            visibility: "Visibility: \(cached.visibility) m"
        )
    }
    
    func refreshAllFavorites() {
        let favorites = dataCoreManager.fetchAllFavorites()
           
        guard !favorites.isEmpty else { return }
        
        let dispatchGroup = DispatchGroup()
        
        for city in favorites {
            dispatchGroup.enter()
            
            locationService.getCoordinates(for: city.cityName) { [weak self] result in
                guard let self else {
                    dispatchGroup.leave()
                    return
                }
                
                switch result {
                case .success(let coordinates):
                    self.repository.fetchCurrentWeather(
                        lon: coordinates.longitude,
                        lat: coordinates.latitude,
                        forceRefresh: true
                    ) { weatherResult in
                        switch weatherResult {
                        case .success(let weather):
                            self.dataCoreManager.updateFavorite(
                                cityName: city.cityName,
                                with: weather
                            )
                        case .failure(let error):
                            print("\(error)")
                        }
                        dispatchGroup.leave()
                    }
                    
                case .failure(_):
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.dataCoreManager.saveContext()
            NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
        }
    }
    
    func removeAllFavorites() {
        let allFavorites = dataCoreManager.fetchAllFavorites()
        NotificationCenter.default.post(name: .updateFromFavoritesScreen, object: nil)
        for city in allFavorites {
            dataCoreManager.deleteFavorite(byName: city.cityName)
        }
    }
    
    func deleteCity(cityName: String) {
        dataCoreManager.deleteFavorite(byName: cityName)
        print("\(cityName)")
    }
}

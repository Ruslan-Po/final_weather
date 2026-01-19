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
                   
                   if case .success(let coordinates) = result {
                       self.repository.fetchCurrentWeather(
                           lon: coordinates.longitude,
                           lat: coordinates.latitude,
                           forceRefresh: true
                       ) { weatherResult in
                           if case .success(let weather) = weatherResult {
                               self.dataCoreManager.updateFavorite(
                                   cityName: city.cityName,
                                   with: weather
                               )
                           }
                           dispatchGroup.leave()
                       }
                   } else {
                       dispatchGroup.leave()
                   }
               }
           }
           
           dispatchGroup.notify(queue: .main) { [weak self] in
               NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
               self?.view?.getWeather()
           }
       }
    
    func removeAllFavorites() {
        let allFavorites = dataCoreManager.fetchAllFavorites()
        NotificationCenter.default.post(
            name: .updateFromFavoritesScreen, object: nil)
        for city in allFavorites {
            dataCoreManager.deleteFavorite(byName: city.cityName)
        }
    }
}


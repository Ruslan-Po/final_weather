import UIKit
import Foundation
import CoreData
internal import _LocationEssentials

class FavoritesViewPresenter: FavoritesViewPresenterProtocol {
    
    weak var view: FavoritesViewControllerProtocol?
    let dataCoreManager: FavoritesStorageProtocol
    private let repository: WeatherRepositoryProtocol
    private let locationService: LocationServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    init(view: FavoritesViewControllerProtocol?,
         dataCoreManager: FavoritesStorageProtocol,
         repository: WeatherRepositoryProtocol,
         locatonService: LocationServiceProtocol,
         notificationService: NotificationServiceProtocol) {
        self.view = view
        self.dataCoreManager = dataCoreManager
        self.repository = repository
        self.locationService = locatonService
        self.notificationService = notificationService
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
            notificationService.cancelWeatherNotification(for: city.cityName)
            dataCoreManager.deleteFavoriteByCityName(byName: city.cityName)
        }
    }
    
    func deleteCity(cityName: String) {
        notificationService.cancelWeatherNotification(for: cityName)
        dataCoreManager.deleteFavoriteByCityName(byName: cityName)
    }
    
    func enableDailyNotifications(for cityName: String, at hour: Int, minute: Int) {
        notificationService.requestAuthorization { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.scheduleDailyNotification(for: cityName, hour: hour, minute: minute)
            } else {
                DispatchQueue.main.async {
                    self.view?.showNotificationPermissionAlert()
                }
            }
        }
    }

    func scheduleOneTimeNotification(for cityName: String, at date: Date) {
        notificationService.requestAuthorization { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.scheduleOnceNotification(for: cityName, date: date)
            } else {
                DispatchQueue.main.async {
                    self.view?.showNotificationPermissionAlert()
                }
            }
        }
    }
    
    func disableNotifications(for cityName: String) {
        notificationService.cancelWeatherNotification(for: cityName)
        print("Notifications disabled for \(cityName)")
    }
    
    
    private func scheduleDailyNotification(for cityName: String, hour: Int, minute: Int) {
        guard let cachedWeather = dataCoreManager.getCurrentWeather(for: cityName) else {
            print("No cached weather for \(cityName)")
            DispatchQueue.main.async { [weak self] in
                self?.view?.showError(" No data for \(cityName)")
            }
            return
        }
        
        let temperature = Int(cachedWeather.temperature)
        let description = cachedWeather.weatherDescription ?? "No Data"
        
        notificationService.scheduleWeatherNotification(
            for: cityName,
            temperature: temperature,
            description: description,
            frequency: .daily(hour: hour, minute: minute)
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.view?.showNotificationScheduled(for: cityName)
        }
        
        print("Daily notification scheduled for \(cityName) at \(hour):\(String(format: "%02d", minute))")
    }
    
    /// Планирует однократное уведомление
    private func scheduleOnceNotification(for cityName: String, date: Date) {
        guard let cachedWeather = dataCoreManager.getCurrentWeather(for: cityName) else {
            print("No cached weather for \(cityName)")
            DispatchQueue.main.async { [weak self] in
                self?.view?.showError("Нет сохранённых данных о погоде для \(cityName)")
            }
            return
        }
        
        let temperature = Int(cachedWeather.temperature)
        let description = cachedWeather.weatherDescription ?? "Нет данных"
        
        notificationService.scheduleWeatherNotification(
            for: cityName,
            temperature: temperature,
            description: description,
            frequency: .once(date: date)
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.view?.showNotificationScheduled(for: cityName)
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        print("One-time notification scheduled for \(cityName) at \(formatter.string(from: date))")
    }
}

import UIKit
import Foundation
internal import _LocationEssentials

protocol WeatherViewPresenterProtocol: AnyObject {
    func fetchWeatherByCoordinates(lon: Double, lat: Double)
}

protocol FavoritesViewPresenterProtocol: AnyObject {
    func loadSavedWeather() -> [FavoriteCity]
    func refreshAllFavorites()
    func removeAllFavorites()
    func deleteCity(cityName: String)
    func createDetailViewModel(from cachedWeather: CachedWeather) -> DetailViewModel
    
    func enableDailyNotifications(for cityName: String, at hour: Int, minute: Int)
    func scheduleOneTimeNotification(for cityName: String, at date: Date)
    func disableNotifications(for cityName: String)
    
}

protocol MainViewPresenterProtocol: WeatherViewPresenterProtocol {
    func fetchWeatherForCurrentLocation()
    func saveCityToFavorites()
    func removeCityFromFavorites()
    func searchWeather(for cityName: String)
    func toggleCityFavoriteStatus()-> Bool
    func searchCity(query: String)
    func enableDailyNotifications(for cityName: String, at hour: Int, minute: Int)
    func scheduleOneTimeNotification(for cityName: String, at date: Date)
    func updateFavoriteCityData(weather: WeatherModel)
    func disableNotifications(for cityName: String)
    func start()
}

protocol ForecastViewPresenterProtocol: WeatherViewPresenterProtocol {
    func fetchUsingSavedLocation()
    func getSavedCityName() -> String?
}

protocol DetailedViewPresenterProtocol: WeatherViewPresenterProtocol {
    func fetchUsingSavedLocation()
    func getSavedCityName() -> String?
}

protocol FavoritesStorageProtocol {
    func saveFavoriteCity(from weatherModel: WeatherModel)
    func fetchAllFavorites() -> [FavoriteCity]
    func findCity(byName name: String) -> FavoriteCity?
    func findCity(byCoordinates lat: Double, lon: Double) -> FavoriteCity?
    func updateFavorite(cityName: String, with weatherModel: WeatherModel)
    func deleteFavorite(_ city: FavoriteCity)
    func deleteFavoriteByCityName(byName cityName: String)
    func isFavorite(cityName: String) -> Bool
    func saveContext()
    
    func getCurrentWeather(for cityName: String) -> CachedWeather?
    func getLatestWeather(for cityName: String) -> CachedWeather?
}


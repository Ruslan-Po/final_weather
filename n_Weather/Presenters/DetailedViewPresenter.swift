import UIKit
import Foundation
internal import _LocationEssentials

final class DetailedViewPresenter: DetailedViewPresenterProtocol {
    weak var view: DetailedViewControllerProtocol?
    private let repository: WeatherRepositoryProtocol
    private let locationStorage: LocationStorageProtocol
    
    init(view: DetailedViewControllerProtocol?,
         repository: WeatherRepositoryProtocol,
         locationStorage: LocationStorageProtocol) {
        self.view = view
        self.repository = repository
        self.locationStorage = locationStorage
    }
    
    func fetchUsingSavedLocation() {
        guard let saved = locationStorage.get() else {
            view?.displayError(NSError(domain: "NoSavedLocation", code: 0))
            return
        }
        fetchWeatherByCoordinates(lon: saved.lon, lat: saved.lat)
    }
    
    func getSavedCityName() -> String? {
        return locationStorage.get()?.cityName
    }
    
    func fetchWeatherByCoordinates(lon: Double, lat: Double) {
        repository.fetchCurrentWeather(lon: lon, lat: lat, forceRefresh: false) { [weak self] results in
            guard let self else { return }
            switch results {
            case .success(let weather):
                let viewModel = self.createDetailViewModel(from: weather)
                self.view?.displayDetail(viewModel)
            case .failure(let error):
                self.view?.displayError(error)
            }
        }
    }
    
    private func createDetailViewModel(from weather: WeatherModel) -> DetailViewModel {
           let forecast = weather.list[0]
           return DetailViewModel(
               windSpeed: "Speed: \(forecast.wind.speed) m/s",
               windDeg: "Degrees: \(forecast.wind.deg)",
               windGust: "Gust: \(forecast.wind.gust ?? 0) m/s",
               feelsLike: "Feels like: \(forecast.main.feelsLike) С°",
               tempMax: "Max Temp: \(forecast.main.tempMax) С°",
               tempMin: "Min Temp: \(forecast.main.tempMin) С°",
               humidity: "Humidity: \(forecast.main.humidity) %",
               pressure: "Pressure: \(forecast.main.pressure) mb",
               visibility: "Visibility: \(forecast.visibility ?? 10000) m"
           )
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
}

import UIKit
import Foundation
internal import _LocationEssentials

protocol WeatherViewPresenterProtocol: AnyObject {
    func fetchWeatherByCoordinates(lon: Double, lat: Double)
}

protocol FavoritesViewPresenterProtocol: AnyObject {
    func loadSavedWeather()
}

protocol MainViewPresenterProtocol: WeatherViewPresenterProtocol {
    func fetchWeatherForCurrentLocation()
    func searchWeather(for cityName: String)
    func searchCity(query: String)
    func start()
}

protocol ForecastViewPresenterProtocol: WeatherViewPresenterProtocol {
    func fetchUsingSavedLocation()
    func getSavedCityName() -> String?
}

protocol DetailedViewPresetnerProtocol: WeatherViewPresenterProtocol {
    func fetchUsingSavedLocation()
    func getSavedCityName() -> String?
}


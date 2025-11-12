import UIKit
import Foundation
internal import _LocationEssentials

protocol WeatherViewPresenterProtocol: AnyObject {
    func fetchWeatherByCoordinates(lon: Double, lat: Double)
}

protocol MainViewPresenterProtocol: WeatherViewPresenterProtocol {
    func fetchWeatherForCurrentLocation()
    func searchWeather(for cityName: String)
    func start()
}

protocol ForecastViewPresenterProtocol: WeatherViewPresenterProtocol {
    func fetchUsingSavedLocation()
    func getSavedCityName() -> String?
}

final class MainViewPresenter {
    weak var view: MainViewControllerProtocol?
    private let client: WeatherClientProtocol
    var locationService: LocationServiceProtocol?
    private let locationStorage: LocationStorageProtocol
    
    init(view: MainViewControllerProtocol,
         locationService: LocationServiceProtocol,
         client: WeatherClientProtocol,
         locationStorage: LocationStorageProtocol) {
        self.view = view
        self.client = client
        self.locationService = locationService
        self.locationStorage = locationStorage
    }
    
    private func createViewModel(from weather: WeatherModel) -> MainViewModel {
        guard let daydata = weather.list.first else {
            return createEmptyViewModel()
        }
        let currentTemp = String(format: "%.1f°C", daydata.main.temp)
        let weatherImage = ImagesByCodeHelper.getImageNameByCode(code: daydata.weather[0].id)
        let sunrise = DateTimeHelper.formatTime(from: weather.city.sunrise)
        let sunset = DateTimeHelper.formatTime(from: weather.city.sunset)
        let cityName = weather.city.name
        
        return MainViewModel(cityName: cityName,
                             currentTemp: currentTemp,
                             weatherImage: weatherImage,
                             sunrise: sunrise,
                             sunset: sunset)
    }
    
    private func createEmptyViewModel() -> MainViewModel {
        return MainViewModel(
            cityName: "",
            currentTemp: "",
            weatherImage: "",
            sunrise: "",
            sunset: ""
        )
    }
    
    private func saveLastLocation(lon: Double, lat: Double, cityName: String) {
        let value = LastLocation(lon: lon, lat: lat, cityName: cityName, updatedAt: Date())
        locationStorage.save(value)
    }
}

extension MainViewPresenter: MainViewPresenterProtocol {
    func start() {
        if let saved = locationStorage.get() {
            fetchWeatherByCoordinates(lon: saved.lon, lat: saved.lat)
        } else {
            fetchWeatherForCurrentLocation()
        }
    }
    
    func fetchWeatherForCurrentLocation() {
        locationService?.getCurrentLocation { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let coordinates):
                let existingName = self.locationStorage.get()?.cityName ?? ""
                self.saveLastLocation(
                    lon: coordinates.longitude,
                    lat: coordinates.latitude,
                    cityName: existingName
                )
                self.fetchWeatherByCoordinates(lon: coordinates.longitude, lat: coordinates.latitude)
            case .failure(let error):
                DispatchQueue.main.async { self.view?.displayError(error: error) }
            }
        }
    }
    
    func searchWeather(for cityName: String) {
        locationService?.getCoordinates(for: cityName) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let coordinates):
                self.saveLastLocation(lon: coordinates.longitude, lat: coordinates.latitude, cityName: cityName)
                self.fetchWeatherByCoordinates(lon: coordinates.longitude, lat: coordinates.latitude)
            case .failure(let error):
                DispatchQueue.main.async {self.view?.displayError(error: error) }
            }
        }
    }
    
    func fetchWeatherByCoordinates(lon: Double, lat: Double) {
        client.fetch(lon: lon, lat: lat) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self.saveLastLocation(lon: lon, lat: lat, cityName: weather.city.name)
                    let vm = self.createViewModel(from: weather)
                    self.view?.displayWeather(data: vm)
                case .failure(let error):
                    self.view?.displayError(error: error)
                }
            }
        }
    }
}

final class ForecastViewPresenter: ForecastViewPresenterProtocol {
    weak var view: ForecastViewControllerProtocol?
    private let client: WeatherClientProtocol
    private let locationStorage: LocationStorageProtocol
    
    init(view: ForecastViewControllerProtocol,
         client: WeatherClientProtocol,
         locationStorage: LocationStorageProtocol) {
        self.view = view
        self.client = client
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
    
    func filter(weatherModel: WeatherModel) -> [Forecast] {
        var addedDays: Set<Date> = []
        var filteredList: [Forecast] = []
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        
        for item in weatherModel.list.dropFirst() {
            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
            let dayStart = calendar.startOfDay(for: date)
            if dayStart != todayStart && addedDays.insert(dayStart).inserted {
                filteredList.append(item)
            }
        }
        return filteredList
    }
    
    func fetchWeatherByCoordinates(lon: Double, lat: Double) {
        client.fetch(lon: lon, lat: lat) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherModel):
                    if let filtered = self?.filter(weatherModel: weatherModel) {
                        self?.view?.getForecast(filtered)
                    }
                    let updated = LastLocation(
                        lon: lon,
                        lat: lat,
                        cityName: weatherModel.city.name,
                        updatedAt: Date()
                    )
                    self?.locationStorage.save(updated)
                case .failure(let error):
                    self?.view?.displayError(error)
                }
            }
        }
    }
}

import UIKit
import Foundation
internal import _LocationEssentials

final class MainViewPresenter: MainViewPresenterProtocol {

    weak var view: MainViewControllerProtocol?
    private let client: WeatherClientProtocol
    var locationService: LocationServiceProtocol?
    private let locationStorage: LocationStorageProtocol
    private let greetingHelper = Greetings()
    private let citySearchService: CitySearchServiceProtocol

    init(view: MainViewControllerProtocol,
         locationService: LocationServiceProtocol,
         client: WeatherClientProtocol,
         citySearchService: CitySearchServiceProtocol,
         locationStorage: LocationStorageProtocol) {
        self.view = view
        self.client = client
        self.locationService = locationService
        self.locationStorage = locationStorage
        self.citySearchService = citySearchService
        
        setupCitySearch()
    }

    private func setupCitySearch() {
        citySearchService.onResultsUpdated = { [weak self] cities in
            self?.view?.displayCitySearchResults(cities)
        }
    }
    
     func createViewModel(from weather: WeatherModel) -> MainViewModel {
        guard let daydata = weather.list.first else {
            return createEmptyViewModel()
        }
        let currentTemp = String(format: "%.1f°C", daydata.main.temp)
        let weatherImage = ImagesByCodeHelper.getImageNameByCode(code: daydata.weather[0].id)
        let sunrise = DateTimeHelper.formatTime(from: weather.city.sunrise)
        let sunset = DateTimeHelper.formatTime(from: weather.city.sunset)
        let cityName = weather.city.name
        let greeting = greetingHelper.setGreetingByTime
        let time = DateTimeHelper.formatTime(from: Date()).uppercased()
        let date = DateTimeHelper.formatDate(from: Date()).uppercased()

        return MainViewModel(cityName: cityName,
                             currentTemp: currentTemp,
                             weatherImage: weatherImage,
                             sunrise: sunrise,
                             sunset: sunset,
                             greeting: greeting,
                             currentTime: time,
                             currentDate: date)
    }

     func createEmptyViewModel() -> MainViewModel {
        return MainViewModel(
            cityName: "",
            currentTemp: "",
            weatherImage: "",
            sunrise: "",
            sunset: "",
            greeting: "",
            currentTime: "",
            currentDate: ""
        )
    }
    
    private func saveLastLocation(lon: Double, lat: Double, cityName: String) {
        let value = LastLocation(lon: lon, lat: lat, cityName: cityName, updatedAt: Date())
        locationStorage.save(value)
        NotificationCenter.default.post(name: .locationDidChange, object: nil)
    }
    
    func searchCity(query: String) {
        citySearchService.search(query: query)
    }

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
                DispatchQueue.main.async {self.view?.displayError(error: error)}
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
                    let viewmodel = self.createViewModel(from: weather)
                    self.view?.displayWeather(data: viewmodel)
                case .failure(let error):
                    self.view?.displayError(error: error)
                }
            }
        }
    }
}

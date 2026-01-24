import UIKit
import Foundation
internal import _LocationEssentials

final class MainViewPresenter: MainViewPresenterProtocol {
 
    
    weak var view: MainViewControllerProtocol?
    private let repository: WeatherRepositoryProtocol
    var locationService: LocationServiceProtocol?
    private let locationStorage: LocationStorageProtocol
    private let greetingHelper = Greetings()
    private let citySearchService: CitySearchServiceProtocol
    private let favoritesStorage: FavoritesStorageProtocol
    private let notificationService: NotificationServiceProtocol
    
    private var currentCityName: String?

    init(view: MainViewControllerProtocol,
         locationService: LocationServiceProtocol,
         repository: WeatherRepositoryProtocol,
         citySearchService: CitySearchServiceProtocol,
         locationStorage: LocationStorageProtocol,
         favoritesStorage: FavoritesStorageProtocol,
         notificationService: NotificationServiceProtocol
         
        ) {
        self.view = view
        self.repository = repository
        self.locationService = locationService
        self.locationStorage = locationStorage
        self.citySearchService = citySearchService
        self.favoritesStorage = favoritesStorage
        self.notificationService = notificationService
        setupCitySearch()

    }

    private func setupCitySearch() {
        citySearchService.onResultsUpdated = { [weak self] cities in
            self?.view?.displayCitySearchResults(cities)
        }
    }
    
    @objc private func favoritesListDidChange (notification: Notification) {
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    private func notifyLocationChanged(cityName: String) {
        NotificationCenter.default.post(
            name: .locationDidChange,
            object: nil,
            userInfo: ["cityName": cityName]
        )
    }
    
     func createViewModel(from weather: WeatherModel) -> MainViewModel {
        guard let dayData = weather.list.first else {
            return createEmptyViewModel()
        }
        let currentTemp = String(format: "%.0f °C", dayData.main.temp)
        let weatherImage = ImagesByCodeHelper.getImageNameByCode(code: dayData.weather[0].id)
        let sunrise = DateTimeHelper.formatTime(from: weather.city.sunrise)
        let sunset = DateTimeHelper.formatTime(from: weather.city.sunset)
        let cityName = weather.city.name
        let greeting = greetingHelper.setGreetingByTime
        let time = DateTimeHelper.formatTime(from: Date()).uppercased()
        let date = DateTimeHelper.formatDate(from: Date()).uppercased()
        let lastUpdated = "Updated: \(DateTimeHelper.updateDateFormater(from: Date()))"

        return MainViewModel(cityName: cityName,
                             currentTemp: currentTemp,
                             weatherImage: weatherImage,
                             sunrise: sunrise,
                             sunset: sunset,
                             greeting: greeting,
                             currentTime: time,
                             currentDate: date,
                             lastUpdated: lastUpdated)
    }
    
    func createViewModelFromStorage(from city: FavoriteCity) -> MainViewModel {
        guard let currentWeather = city.currentWeather else {
            return createEmptyViewModel()
        }
        
        let currentTemp = String(format: "%.0f°C", currentWeather.temperature)
        let weatherImage = ImagesByCodeHelper.getImageNameByCode(code: Int(currentWeather.weatherId))
        let sunrise = DateTimeHelper.formatTime(from: Int(city.sunrise))
        let sunset = DateTimeHelper.formatTime(from: Int(city.sunset))
        let cityName = city.cityName
        let greeting = greetingHelper.setGreetingByTime
        let time = DateTimeHelper.formatTime(from: Date()).uppercased()
        let date = DateTimeHelper.formatDate(from: Date()).uppercased()
        var lastUpdated: String?
           if let cachedAt = city.cachedAt {
               lastUpdated = "Cached: \(DateTimeHelper.updateDateFormater(from: cachedAt))"
           }

        return MainViewModel(
            cityName: cityName,
            currentTemp: currentTemp,
            weatherImage: weatherImage,
            sunrise: sunrise,
            sunset: sunset,
            greeting: greeting,
            currentTime: time,
            currentDate: date,
            lastUpdated: lastUpdated
        )
    }
    
    func loadFromStorage() -> Bool {
        if let cityName = locationStorage.get()?.cityName,
           let city = favoritesStorage.findCity(byName: cityName) {
            let viewModel = createViewModelFromStorage(from: city)
            view?.displayWeather(data: viewModel)
            return true
        }
        if let firstCity = favoritesStorage.fetchAllFavorites().first {
            let viewModel = createViewModelFromStorage(from: firstCity)
            view?.displayWeather(data: viewModel)
            return true
        }
        return false
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
            currentDate: "",
            lastUpdated: nil
        )
    }
    
    private func saveLastLocation(lon: Double, lat: Double, cityName: String) {
        let value = LastLocation(lon: lon, lat: lat, cityName: cityName, updatedAt: Date())
        locationStorage.save(value)
        currentCityName = value.cityName
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
        repository.fetchCurrentWeather(lon: lon, lat: lat, forceRefresh: false) {[weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self.currentCityName = weather.city.name
                    let value = LastLocation(lon: lon, lat: lat,
                                             cityName: weather.city.name,
                                             updatedAt: Date())
                                   self.locationStorage.save(value)
                    let viewmodel = self.createViewModel(from: weather)

                    if self.favoritesStorage.isFavorite(cityName: weather.city.name) {
                        self.favoritesStorage.updateFavorite(cityName: weather.city.name, with: weather)
                    }
                    self.notifyLocationChanged(cityName: weather.city.name)
                    self.view?.displayWeather(data: viewmodel)
                case .failure(let error):
                    if self.loadFromStorage() {
                           print("Loaded from cache")
                       } else {
                           self.view?.displayError(error: error)
                       }
                }
            }
        }
    }
    
    func saveCityToFavorites() {
        guard let lastLocation = locationStorage.get() else {return}
        
        repository.fetchCurrentWeather(lon: lastLocation.lon, lat: lastLocation.lat, forceRefresh: false) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self.favoritesStorage.saveFavoriteCity(from: weather)
                    self.updateFavoriteCityData(weather: weather)
                    NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
                    self.view?.updateFavoriteStatus()
                case .failure(let error):
                    self.view?.displayError(error: error)
                }
            }
        }
    }
    
    func removeCityFromFavorites() {
        guard let lastLocation = locationStorage.get() else { return }
        
        favoritesStorage.deleteFavoriteByCityName(byName: lastLocation.cityName)
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
        view?.updateFavoriteStatus()
    }
    
    
    func toggleCityFavoriteStatus() -> Bool {

        if favoritesStorage.isFavorite(cityName: currentCityName ?? ""){
            return true
        } else {
            return false
        }
    }
    
    func updateFavoriteCityData(weather: WeatherModel) {
        favoritesStorage.updateFavorite(cityName: currentCityName ?? "", with: weather)
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
    
    private func scheduleDailyNotification(for cityName: String, hour: Int, minute: Int) {
        guard let cachedWeather = favoritesStorage.getCurrentWeather(for: cityName) else {
            DispatchQueue.main.async { [weak self] in
                self?.view?.showError("No data for \(cityName)")
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
    }

    private func scheduleOnceNotification(for cityName: String, date: Date) {
        guard let cachedWeather = favoritesStorage.getCurrentWeather(for: cityName) else {
            DispatchQueue.main.async { [weak self] in
                self?.view?.showError("No data for  \(cityName)")
            }
            return
        }
        
        let temperature = Int(cachedWeather.temperature)
        let description = cachedWeather.weatherDescription ?? "No Data"
        
        notificationService.scheduleWeatherNotification(
            for: cityName,
            temperature: temperature,
            description: description,
            frequency: .once(date: date)
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.view?.showNotificationScheduled(for: cityName)
        }
    }
    func disableNotifications(for cityName: String) {
        notificationService.cancelWeatherNotification(for: cityName)
    }
}

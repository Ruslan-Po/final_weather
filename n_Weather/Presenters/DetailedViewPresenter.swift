import UIKit
import Foundation
internal import _LocationEssentials

final class DetailedViewPresenter: DetailedViewPresetnerProtocol {
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
        repository.fetchCurrentWeather(lon: lon, lat: lat, forceRefresh: false) {[weak self] results in
            guard let self else { return }
            switch results {
            case .success(let detailed):
                self.view?.getWeatherDetail(detailed)
            case .failure(let error):
                self.view?.displayError(error)
            }
        }
        
    }
}

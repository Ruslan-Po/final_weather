import UIKit
import Foundation
internal import _LocationEssentials

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
            let date = Date(timeIntervalSince1970: TimeInterval(item.datetime))
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

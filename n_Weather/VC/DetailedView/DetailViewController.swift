import UIKit

protocol DetailedViewControllerProtocol: AnyObject {
    func getWeatherDetail(_ detailedWeather: WeatherModel)
    func displayError(_ error: Error)
}

class DetailViewController: UIViewController {
    var presenter: DetailedViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.fetchUsingSavedLocation()
        subscribeToNotifications()
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateForecast),
            name: .locationDidChange,
            object: nil
        )
    }
    
    @objc private func updateForecast() {
        presenter?.fetchUsingSavedLocation()
        print("Update")
    }
}

extension DetailViewController: DetailedViewControllerProtocol {
    func getWeatherDetail(_ detailedWeather: WeatherModel) {
        print("City: \(detailedWeather.city.name)")
        print("wind speed:\(detailedWeather.list[0].wind.speed)")
        print("wind geg:\(detailedWeather.list[0].wind.deg)")
        print("wind gust:\(detailedWeather.list[0].wind.gust)")
        print("humidity: \(detailedWeather.list[0].main.humidity)")
        print("temp_max:\(detailedWeather.list[0].main.tempMax)")
        print("temp_min:\(detailedWeather.list[0].main.tempMin)")
        print("feels-Like:\(detailedWeather.list[0].main.feelsLike)")
    }
    
    func displayError(_ error: any Error) {
        print("\(error)")
    }
}

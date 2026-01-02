import UIKit

protocol DetailedViewControllerProtocol: AnyObject {
    func getWeatherDetail(_ detailedWeather: WeatherModel)
    func displayError(_ error: Error)
}

class DetailViewController: UIViewController {
    var presenter: DetailedViewPresenter!
    
    lazy var windStackView: WindView = {
        let stackView = WindView(imageName: "wind")
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var temperatureStackView: TempView = {
        let stackView = TempView(imageName: "temp")
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var humidityStackView: SingleStack = {
       let stackView = SingleStack(imageName: "humidity")
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var pressureStackView: SingleStack = {
        let stackView = SingleStack(imageName: "pressure")
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var visibilityStackView: SingleStack = {
        let stackView = SingleStack(imageName: "visibility")
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var detailStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [temperatureStackView,
                                                       windStackView,
                                                       humidityStackView,
                                                       pressureStackView,
                                                       visibilityStackView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = Layout.Spacing.medium
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
    func setupUI(){
        view.addSubview(detailStackView)
        
        NSLayoutConstraint.activate([
            detailStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                 constant: Layout.mediumPadding),
            detailStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)

        ])
    }
}

extension DetailViewController: DetailedViewControllerProtocol {
    func getWeatherDetail(_ detailedWeather: WeatherModel) {
        windStackView.config(speed:
                                "Speed \(detailedWeather.list[0].wind.speed) m/s",
                             deg:
                                "Degreese: \(detailedWeather.list[0].wind.deg) ",
                             gust:
                                "Gust \(detailedWeather.list[0].wind.gust)")
     
        temperatureStackView.config(feelsLike:
                                        "Feels like: \(detailedWeather.list[0].main.feelsLike)",
                                    max:
                                        "Max Temp: \(detailedWeather.list[0].main.tempMax)",
                                    min:
                                        "Min Temp: \(detailedWeather.list[0].main.tempMin)")
        humidityStackView.config(text:
                                    "Humidity: \(detailedWeather.list[0].main.humidity)")
        pressureStackView.config(text:
                                    "Pressure: \(detailedWeather.list[0].main.pressure)")
        visibilityStackView.config(text:
                                    "Visibility: \(detailedWeather.list[0].visibility)")
        
    }
    func displayError(_ error: any Error) {
        print("\(error)")
    }
}

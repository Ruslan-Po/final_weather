import UIKit

protocol DetailedViewControllerProtocol: AnyObject {
    func getWeatherDetail(_ detailedWeather: WeatherModel)
    func getWeatherDetailFromCache(_ cachedWeather: CachedWeather)
    func displayError(_ error: Error)
}

class DetailViewController: UIViewController {
    var presenter: DetailedViewPresenter!
    var cachedWeatherToShow: CachedWeather?
    var showCloseButton: Bool = false
    
    lazy var windStackView: WindView = {
        let stackView = WindView(imageName: "wind")
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
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
        stackView.spacing = Layout.Spacing.small
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        view.backgroundColor = .systemBackground
        
        closeButton.isHidden = !showCloseButton
        
        if let cached = cachedWeatherToShow {
            getWeatherDetailFromCache(cached)
        } else {
            presenter?.fetchUsingSavedLocation()
            subscribeToNotifications()
        }
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
        view.addSubview(closeButton) 
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.smallPadding),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.smallPadding),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
    
            detailStackView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: Layout.extraSmallPadding),
            detailStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.mediumPadding),
            detailStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.mediumPadding),
            detailStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
extension DetailViewController: DetailedViewControllerProtocol {
    
    func getWeatherDetail(_ detailedWeather: WeatherModel) {
        let forecast = detailedWeather.list[0]
        
        windStackView.config(
            speed: "Speed: \(forecast.wind.speed) m/s",
            deg: "Degrees: \(forecast.wind.deg)",
            gust: "Gust \(forecast.wind.gust ?? 0) m/s"
        )
        
        temperatureStackView.config(
            feelsLike: "Feels like: \(forecast.main.feelsLike) С°",
            max: "Max Temp: \(forecast.main.tempMax) С°",
            min: "Min Temp: \(forecast.main.tempMin) С°"
        )
        
        humidityStackView.config(text: "Humidity: \(forecast.main.humidity) %")
        pressureStackView.config(text: "Pressure: \(forecast.main.pressure) mb")
        visibilityStackView.config(text: "Visibility: \(forecast.visibility ?? 10000) m")
    }
    
    func getWeatherDetailFromCache(_ cachedWeather: CachedWeather) {
        windStackView.config(
            speed: "Speed: \(cachedWeather.windSpeed) m/s",
            deg: "Degrees: \(cachedWeather.windDeg)",
            gust: "Gust \(cachedWeather.windGust) m/s"
        )
        
        temperatureStackView.config(
            feelsLike: "Feels like: \(cachedWeather.feelsLike) С°",
            max: "Max Temp: \(cachedWeather.tempMax) С°",
            min: "Min Temp: \(cachedWeather.tempMin) С°"
        )
        
        humidityStackView.config(text: "Humidity: \(cachedWeather.humidity) %")
        pressureStackView.config(text: "Pressure: \(cachedWeather.pressure) mb")
        visibilityStackView.config(text: "Visibility: \(cachedWeather.visibility) m")
    }
    
    func displayError(_ error: any Error) {
        print("\(error)")
    }
    
}





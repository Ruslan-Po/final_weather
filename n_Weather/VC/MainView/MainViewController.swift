import UIKit

protocol MainViewControllerProtocol: AnyObject {
    func displayWeather(data: MainViewModel)
    func displayError(error: Error)
}

class MainViewController: UIViewController {
    var presenter: MainViewPresenterProtocol!
    var router: RouterProtocol?

    lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 25, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var weatherImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "-- °C"
        label.font = UIFont.systemFont(ofSize: 70, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var greetingsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints=false
        return label
    }()

    lazy var dateTimeStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [greetingsLabel, timeLabel, dateLabel])
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = "City name"
        field.delegate = self
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    lazy var forecastButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemGray2
        button.setTitle("Forecast".uppercased(), for: .normal)
        button.tintColor = .white
        button.isEnabled = true
        button.addTarget(self, action: #selector(showForecast), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var sunsetStackView: SunTimeView = {
        let stackView = SunTimeView(imageName: "sunset")
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var sunriseStackView: SunTimeView = {
        let stackView = SunTimeView(imageName: "sunrise")
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var sunStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [sunriseStackView, sunsetStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        let pointSize: CGFloat = 25.0
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: pointSize)
        let buttonImage = UIImage(systemName: "location.app.fill", withConfiguration: symbolConfig)
        button.tintColor = .gray

        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(getUserLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

     @objc func getUserLocation() {
         presenter.fetchWeatherForCurrentLocation()
    }

    @objc func showForecast() {
        router?.showForecastScreen()
    }

    func setupUI() {
        view.addSubview(forecastButton)
        view.addSubview(weatherImage)
        view.addSubview(temperatureLabel)
        view.addSubview(dateTimeStackView)
        view.addSubview(sunStackView)
        view.addSubview(textField)
        view.addSubview(locationButton)
        view.addSubview(cityLabel)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            textField.trailingAnchor.constraint(equalTo: locationButton.leadingAnchor, constant: -10),

            locationButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 10),
            locationButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            cityLabel.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 10),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            weatherImage.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 10),
            weatherImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weatherImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: 10),

            dateTimeStackView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 15),
            dateTimeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            dateTimeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            sunStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            sunStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            sunStackView.topAnchor.constraint(equalTo: dateTimeStackView.bottomAnchor, constant: 10),

            forecastButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            forecastButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forecastButton.heightAnchor.constraint(equalToConstant: 40),
            forecastButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6

        presenter.start()
        setupUI()
    }
}

extension MainViewController: MainViewControllerProtocol {

    func displayWeather(data: MainViewModel) {
        sunsetStackView.timeLabel.text = data.sunset
        sunriseStackView.timeLabel.text = data.sunrise
        temperatureLabel.text = data.currentTemp
        weatherImage.image = UIImage(named: data.weatherImage)
        cityLabel.text = data.cityName
        greetingsLabel.text = data.greeting
        timeLabel.text = data.currentTime
        dateLabel.text = data.currentDate
    }

    func displayError(error: Error) {
       showError(error)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        presenter.searchWeather(for: textField.text ?? " ")
        textField.resignFirstResponder()
        textField.text = ""
        return true
    }
}

import UIKit

protocol MainViewControllerProtocol: AnyObject {
    func displayWeather(data: MainViewModel)
    func displayError(error: Error)
}

class MainViewController: UIViewController {
    var presenter: MainViewPresenterProtocol!

    lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = AppColors.secondary
        label.font = UIFont.systemFont(ofSize: 25, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var weatherImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
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
        stack.spacing = Layout.Spacing.small
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
        stackView.spacing = Layout.Spacing.small
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        let pointSize: CGFloat = 25.0
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: pointSize)
        let buttonImage = UIImage(systemName: "location.app.fill", withConfiguration: symbolConfig)
        button.tintColor = AppColors.tint

        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(getUserLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

     @objc func getUserLocation() {
         presenter.fetchWeatherForCurrentLocation()
    }

    func setupUI() {
        view.addSubview(weatherImage)
        view.addSubview(temperatureLabel)
        view.addSubview(dateTimeStackView)
        view.addSubview(sunStackView)
        view.addSubview(textField)
        view.addSubview(locationButton)
        view.addSubview(cityLabel)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.smallPadding),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.extraLargePadding),
            textField.trailingAnchor.constraint(equalTo: locationButton.leadingAnchor, constant: -Layout.smallPadding),

            locationButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: Layout.smallPadding),
            locationButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.smallPadding),
            locationButton.widthAnchor.constraint(equalToConstant: Layout.constansWidth),
            locationButton.heightAnchor.constraint(equalToConstant: Layout.constansHeight),

            cityLabel.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: Layout.smallPadding),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            weatherImage.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: Layout.smallPadding),
            weatherImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.largePadding),
            weatherImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.largePadding),
            weatherImage.heightAnchor.constraint(equalToConstant: 220),

            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: Layout.smallPadding),

            dateTimeStackView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: Layout.mediumPadding),
            dateTimeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.extraLargePadding),
            dateTimeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.extraLargePadding),

            sunStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.largePadding),
            sunStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.largePadding),
            sunStackView.topAnchor.constraint(equalTo: dateTimeStackView.bottomAnchor, constant: Layout.smallPadding)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.primary

        presenter.start()
        setupUI()
    }
}

extension MainViewController: MainViewControllerProtocol {

    func displayWeather(data: MainViewModel) {
        sunsetStackView.configure(with: data.sunset)
        sunriseStackView.configure(with: data.sunrise)
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

import UIKit

protocol MainViewControllerProtocol: AnyObject {
    func displayWeather(data: MainViewModel)
    func displayError(error: Error)
    func displayCitySearchResults(_ cities: [String])
    func showCityAdded()
}

class MainViewController: UIViewController {
    var presenter: MainViewPresenterProtocol!
    private let searchController = UISearchController()
    private var searchWorkItem: DispatchWorkItem?
    
    private var searchResults: [String] = []
    
    private let searchResultsTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isHidden = true
        return table
    }()
    
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
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let pointSize: CGFloat = 25.0
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: pointSize)
        let buttonImage = UIImage(systemName: "star.square", withConfiguration: symbolConfig)
        button.tintColor = AppColors.tint
        
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(addToFavoriteFu), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func addToFavoriteFu(){
        presenter.saveCityToFavorites()
    }
    
    @objc func getUserLocation() {
        presenter.fetchWeatherForCurrentLocation()

    }
    
    func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }
    
    private func setupSearchResultsTableView() {
        view.addSubview(searchResultsTableView)
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        
        NSLayoutConstraint.activate([
            searchResultsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")
    }
    
    func setupUI() {
        view.addSubview(weatherImage)
        view.addSubview(temperatureLabel)
        view.addSubview(dateTimeStackView)
        view.addSubview(sunStackView)
        view.addSubview(locationButton)
        view.addSubview(cityLabel)
        view.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.smallPadding),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            locationButton.leadingAnchor.constraint(equalTo: cityLabel.trailingAnchor, constant: Layout.smallPadding),
            locationButton.bottomAnchor.constraint(equalTo: cityLabel.bottomAnchor),
            locationButton.widthAnchor.constraint(equalToConstant: Layout.constansWidth),
            locationButton.heightAnchor.constraint(equalToConstant: Layout.constansHeight),
            
            favoriteButton.leadingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: Layout.smallPadding),
            favoriteButton.bottomAnchor.constraint(equalTo: cityLabel.bottomAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: Layout.constansWidth),
            favoriteButton.heightAnchor.constraint(equalToConstant: Layout.constansHeight),
            
            
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
        setupSearchResultsTableView()
        setupSearchBar()
    }
}

extension MainViewController: MainViewControllerProtocol {
    func showCityAdded() {
        print("cityAdded")
    }
    
    func displayCitySearchResults(_ cities: [String]) {
        searchResults = cities
        searchResultsTableView.reloadData()
        searchResultsTableView.isHidden = cities.isEmpty
        
    }
    
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

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
            let text = searchController.searchBar.text ?? ""
            searchWorkItem?.cancel()

            if text.isEmpty {
                searchResults = []
                searchResultsTableView.reloadData()
                searchResultsTableView.isHidden = true
                return
            }
            let workItem = DispatchWorkItem { [weak self] in
                self?.presenter.searchCity(query: text)
            }
            searchWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        cell.textLabel?.text = searchResults[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let city = searchResults[indexPath.row]
        searchController.isActive = false
        searchResultsTableView.isHidden = true
        presenter.searchWeather(for: city)
    }
}

extension MainViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        searchResultsTableView.isHidden = true
        searchResults = []
    }
}

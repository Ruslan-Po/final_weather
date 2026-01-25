import UIKit

protocol MainViewControllerProtocol: AnyObject {
    func displayWeather(data: MainViewModel)
    func displayError(error: Error)
    func displayCitySearchResults(_ cities: [String])
    func updateFavoriteStatus()
    func showNotificationScheduled(for city: String)
    func showError(_ message: String)
}

class MainViewController: UIViewController {
    var presenter: MainViewPresenterProtocol!
    private let searchController = UISearchController()
    private var searchWorkItem: DispatchWorkItem?
    
    private var searchResults: [String] = []
    private var hasNotificationsEnabled: Bool = false
    private var currentCityName: String = ""
    
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
    
    lazy var favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.square")
        imageView.tintColor = AppColors.tint
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleFavoriteTap))
        imageView.addGestureRecognizer(tap)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "location.square.fill")
        imageView.tintColor = AppColors.tint
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(getUserLocation))
        imageView.addGestureRecognizer(tap)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var pushImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bell.square")
        imageView.tintColor = AppColors.tint
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePushNotifications))
        imageView.addGestureRecognizer(tap)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textAlignment = .left
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func updateFavoriteButtonState() {
        let isFavorite = presenter.toggleCityFavoriteStatus()
        let imageName = isFavorite ? "star.square.fill" : "star.square"
        favoriteImageView.image = UIImage(systemName: imageName)
    }
    
    private func updateLastUpdatedLabelVisibility() {
        let isFavorite = presenter.toggleCityFavoriteStatus()
        lastUpdatedLabel.isHidden = !isFavorite
    }
    
    private func updateNotificationButtonIcon() {
        let imageName = hasNotificationsEnabled ? "bell.square.fill" : "bell.square"
        pushImageView.image = UIImage(systemName: imageName)
    }
    
    @objc func handleFavoriteTap() {
        favoriteImageView.animateTap()
        
        if presenter.toggleCityFavoriteStatus() {
            presenter.removeCityFromFavorites()
            
            if hasNotificationsEnabled {
                presenter.disableNotifications(for: currentCityName)
                hasNotificationsEnabled = false
                updateNotificationButtonIcon()
                
                NotificationStateManager.shared.setNotificationEnabled(false, for: currentCityName)
                
                NotificationCenter.default.post(
                    name: .notificationStateDidChange,
                    object: nil,
                    userInfo: ["cityName": currentCityName, "enabled": false]
                )
            }
        } else {
            presenter.saveCityToFavorites()
        }
    }
    
    @objc func togglePushNotifications() {
        pushImageView.animateTap()
        
        if hasNotificationsEnabled {
            presenter.disableNotifications(for: currentCityName)
            hasNotificationsEnabled = false
            updateNotificationButtonIcon()
            
            NotificationStateManager.shared.setNotificationEnabled(false, for: currentCityName)
            
            NotificationCenter.default.post(
                name: .notificationStateDidChange,
                object: nil,
                userInfo: ["cityName": currentCityName, "enabled": false]
            )
        } else {
            showNotificationSettings(for: currentCityName)
        }
    }
    
    @objc func getUserLocation() {
        locationImageView.animateTap()
        presenter.fetchWeatherForCurrentLocation()
    }
    
    private func showNotificationSettings(for cityName: String) {
        let settingsView = NotificationSettingsView()
        settingsView.delegate = self
        settingsView.show(in: view)
    }
    
    func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.tintColor = .black
        
        let searchTextField = searchController.searchBar.searchTextField
        searchTextField.backgroundColor = .white
        searchTextField.textColor = .black
        
        searchTextField.layer.shadowColor = UIColor.black.cgColor
        searchTextField.layer.shadowOffset = CGSize(width: 0, height: 1)
        searchTextField.layer.shadowOpacity = 0.1
        searchTextField.layer.shadowRadius = 2
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
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifiers.searchCell)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoritesDidChange),
            name: .favoritesDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationStateDidChange),
            name: .notificationStateDidChange,
            object: nil
        )
    }
    
    @objc private func handleNotificationStateDidChange(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let cityName = userInfo["cityName"] as? String,
              let enabled = userInfo["enabled"] as? Bool else {
            return
        }
        
        if cityName == currentCityName {
            DispatchQueue.main.async { [weak self] in
                self?.hasNotificationsEnabled = enabled
                self?.updateNotificationButtonIcon()
            }
        }
    }
    
    @objc private func handleFavoritesDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.updateFavoriteButtonState()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI() {
        view.addSubview(weatherImage)
        view.addSubview(temperatureLabel)
        view.addSubview(dateTimeStackView)
        view.addSubview(sunStackView)
        view.addSubview(locationImageView)
        view.addSubview(cityLabel)
        view.addSubview(favoriteImageView)
        view.addSubview(lastUpdatedLabel)
        view.addSubview(pushImageView)
        
        NSLayoutConstraint.activate([
            lastUpdatedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.extraSmallPadding),
            lastUpdatedLabel.trailingAnchor.constraint(equalTo: favoriteImageView.trailingAnchor, constant: -5),
            
            cityLabel.topAnchor.constraint(equalTo: lastUpdatedLabel.bottomAnchor, constant: Layout.smallPadding),
            cityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.largePadding),
            
            pushImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.mediumPadding),
            pushImageView.centerYAnchor.constraint(equalTo: cityLabel.centerYAnchor),
            pushImageView.widthAnchor.constraint(equalToConstant: Layout.constantWidth),
            pushImageView.heightAnchor.constraint(equalToConstant: Layout.constantHeight),
            
            favoriteImageView.trailingAnchor.constraint(equalTo: pushImageView.leadingAnchor, constant: -Layout.extraSmallPadding),
            favoriteImageView.centerYAnchor.constraint(equalTo: cityLabel.centerYAnchor),
            favoriteImageView.widthAnchor.constraint(equalToConstant: Layout.constantWidth),
            favoriteImageView.heightAnchor.constraint(equalToConstant: Layout.constantHeight),
            
            locationImageView.trailingAnchor.constraint(equalTo: favoriteImageView.leadingAnchor, constant: -Layout.extraSmallPadding),
            locationImageView.centerYAnchor.constraint(equalTo: cityLabel.centerYAnchor),
            locationImageView.widthAnchor.constraint(equalToConstant: Layout.constantWidth),
            locationImageView.heightAnchor.constraint(equalToConstant: Layout.constantHeight),
            
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
        setupNotifications()
    }
}

extension MainViewController: MainViewControllerProtocol {
    func updateFavoriteStatus() {
        updateFavoriteButtonState()
        updateLastUpdatedLabelVisibility()
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
        lastUpdatedLabel.text = data.lastUpdated
        
        currentCityName = data.cityName
        
        updateFavoriteButtonState()
        updateLastUpdatedLabelVisibility()
        
        hasNotificationsEnabled = NotificationStateManager.shared.isNotificationEnabled(for: data.cityName)
        updateNotificationButtonIcon()
    }
    
    func displayError(error: Error) {
        showError(error)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showNotificationScheduled(for city: String) {
        hasNotificationsEnabled = true
        updateNotificationButtonIcon()
    }
}

extension MainViewController: NotificationSettingsViewDelegate {
    func notificationSettingsView(_ view: NotificationSettingsView, didScheduleWithFrequency frequency: NotificationFrequency) {
        guard !currentCityName.isEmpty else {
            view.hide()
            return
        }
        
        let isFavorite = presenter.toggleCityFavoriteStatus()
        if !isFavorite {
            presenter.saveCityToFavorites()
            updateFavoriteButtonState()
        }
        
        switch frequency {
        case .daily(let hour, let minute):
            presenter.enableDailyNotifications(for: currentCityName, at: hour, minute: minute)
            
        case .once(let date):
            presenter.scheduleOneTimeNotification(for: currentCityName, at: date)
        }
        
        NotificationStateManager.shared.setNotificationEnabled(true, for: currentCityName)
        
        NotificationCenter.default.post(
            name: .notificationStateDidChange,
            object: nil,
            userInfo: ["cityName": currentCityName, "enabled": true]
        )
        
        view.hide()
    }
    
    func notificationSettingsViewDidCancel(_ view: NotificationSettingsView) {
        view.hide()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.searchCell, for: indexPath)
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

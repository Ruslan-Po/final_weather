import UIKit

protocol FavoritesViewControllerProtocol: AnyObject {
    func getWeather()
    func showError(_ message: String)
    func showNotificationScheduled(for city: String)
}

class FavoritesViewController: UIViewController {
    
    var presenter: FavoritesViewPresenterProtocol!
    var favoriteCities: [FavoriteCity] = []
    
    private struct NotificationContext {
        let cityName: String
        weak var cell: FavoritesTableViewCell?
    }
    
    private var currentNotificationContext: NotificationContext?
    
    
    lazy var favoritesCityTableView: FavoriteTableView = {
        let view = FavoriteTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var refreshAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Refresh", for: .normal)
        button.backgroundColor = AppColors.background
        button.layer.cornerRadius = 8.0
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(refreshAllCities), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    lazy var removeAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove All", for: .normal)
        button.backgroundColor = AppColors.background
        button.layer.cornerRadius = 8.0
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(removeAllCities), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [refreshAllButton, removeAllButton])
        stack.axis = .horizontal
        stack.spacing = Layout.mediumPadding
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    @objc private func buttonPressed(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
                sender.alpha = 0.7
            }
        )
    }
    
    @objc private func buttonReleased(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                sender.transform = .identity
                sender.alpha = 1.0
            }
        )
    }
    
    @objc private func refreshAllCities() {
        favoritesCityTableView.showLoadingStateForAllCells()
        presenter.refreshAllFavorites()
    }
    
    @objc private func removeAllCities() {
        presenter.removeAllFavorites()
        getWeather()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFavoritesChange),
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

        DispatchQueue.main.async { [weak self] in
            self?.favoritesCityTableView.updateNotificationState(for: cityName, enabled: enabled)
        }
    }
    
    @objc private func handleFavoritesChange() {
        DispatchQueue.main.async { [weak self] in
            self?.getWeather()
        }
    }
    
    private func setupDaySelection() {
        favoritesCityTableView.onDaySelected = { [weak self] cachedWeather in
            self?.openDetailScreen(with: cachedWeather)
        }
        favoritesCityTableView.onCityDeleted = { [weak self] cityName in
            self?.deleteCity(cityName: cityName)
        }
    }
    
    private func deleteCity(cityName: String) {
        presenter.deleteCity(cityName: cityName)
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    private func openDetailScreen(with cachedWeather: CachedWeather) {
        let detailVC = DetailViewController()
        detailVC.detailToShow = presenter.createDetailViewModel(from: cachedWeather)
        detailVC.showCloseButton = true
        detailVC.modalPresentationStyle = .fullScreen
        present(detailVC, animated: true)
        
        if let sheet = detailVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(favoritesCityTableView)
        view.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            favoritesCityTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            favoritesCityTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            favoritesCityTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            favoritesCityTableView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -Layout.mediumPadding),
            
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.mediumPadding),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.mediumPadding),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.mediumPadding),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Layout.constantHeight)
        ])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
        setupDaySelection()
        getWeather()
        
        favoritesCityTableView.cellDelegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension FavoritesViewController: FavoritesViewControllerProtocol {
    
    func showNotificationScheduled(for city: String) {
        let alert = UIAlertController(
            title: "Done",
            message: "Notifications are scheduled for \(city)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
    
    func getWeather() {
        favoriteCities = presenter.loadSavedWeather()
        favoritesCityTableView.displayFavoriteCitiesTable(favorite: favoriteCities)
    }
}


extension FavoritesViewController: FavoritesTableViewCellDelegate {
    
    func favoritesCell(_ cell: FavoritesTableViewCell, didTapNotificationForCity cityName: String) {
        let settingsView = NotificationSettingsView()
        settingsView.delegate = self
        settingsView.show(in: view)
        
        currentNotificationContext = NotificationContext(
            cityName: cityName,
            cell: cell
        )
    }
    
    func favoritesCell(_ cell: FavoritesTableViewCell, didRequestDisableNotificationForCity cityName: String) {
        presenter.disableNotifications(for: cityName)
        cell.updateNotificationState(enabled: false)
        
        NotificationCenter.default.post(
                  name: .notificationStateDidChange,
                  object: nil,
                  userInfo: ["cityName": cityName, "enabled": false]
              )
    }
}


extension FavoritesViewController: NotificationSettingsViewDelegate {
    
    func notificationSettingsView(_ view: NotificationSettingsView, didScheduleWithFrequency frequency: NotificationFrequency) {
        guard let context = currentNotificationContext else {
            view.hide()
            return
        }
        
        let cityName = context.cityName
        
        switch frequency {
        case .daily(let hour, let minute):
            presenter.enableDailyNotifications(for: cityName, at: hour, minute: minute)
            
        case .once(let date):
            presenter.scheduleOneTimeNotification(for: cityName, at: date)
        }
        
        context.cell?.updateNotificationState(enabled: true)
        
        NotificationCenter.default.post(
                    name: .notificationStateDidChange,
                    object: nil,
                    userInfo: ["cityName": cityName, "enabled": true]
                )
        
        view.hide()
        currentNotificationContext = nil
    }
    
    func notificationSettingsViewDidCancel(_ view: NotificationSettingsView) {
        view.hide()
        currentNotificationContext = nil
    }
}

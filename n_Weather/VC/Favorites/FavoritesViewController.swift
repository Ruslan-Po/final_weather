import UIKit

protocol FavoritesViewControllerProtocol: AnyObject {
    func getWeather()
    func showError(_ error: Error)
}

class FavoritesViewController: UIViewController {
    var presenter: FavoritesViewPresenterProtocol!
    var favoriteCities: [FavoriteCity] = []
    
    
    lazy var favoritesCityTableView: FavotiteTableView = {
        let view = FavotiteTableView()
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension FavoritesViewController: FavoritesViewControllerProtocol {
    func getWeather() {
        favoriteCities = presenter.loadSavedWeather()
        favoritesCityTableView.displayFavoriteCitiesTable(favorite: favoriteCities)
    }
}

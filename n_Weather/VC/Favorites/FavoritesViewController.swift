import UIKit

protocol FavoritesViewControllerProtocol: AnyObject {
    func getWeather()
    func showError(_ error: Error)
}

class FavoritesViewController: UIViewController {
    var presenter: FavoritesViewPresenterProtocol!
    var favoriteCityes: [FavoriteCity] = []
    
    // MARK: - UI Elements
    
    lazy var favoritesCityesTableView: FavotitesTableView = {
        let view = FavotitesTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var refreshAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Refresh All", for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 8.0
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(refreshAllCities), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var removeAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove All", for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 8.0
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(removeAllCities), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    // MARK: - Actions
    
    @objc private func refreshAllCities() {
        presenter.refreshAllFavorites()
    }
    
    @objc private func removeAllCities() {
        presenter.removeAllFavorites()
        getWeather()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    // MARK: - Setup Methods
    
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
        favoritesCityesTableView.onDaySelected = { [weak self] cachedWeather in
            self?.openDetailScreen(with: cachedWeather)
        }
    }
    
    private func openDetailScreen(with cachedWeather: CachedWeather) {
        let detailVC = DetailViewController()
        detailVC.cachedWeatherToShow = cachedWeather
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
        view.addSubview(favoritesCityesTableView)
        view.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            // TableView constraints
            favoritesCityesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            favoritesCityesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            favoritesCityesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            favoritesCityesTableView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -Layout.mediumPadding),
            
            // Buttons stack constraints
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.mediumPadding),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.mediumPadding),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.mediumPadding),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Lifecycle
    
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

// MARK: - FavoritesViewControllerProtocol

extension FavoritesViewController: FavoritesViewControllerProtocol {
    func getWeather() {
        favoriteCityes = presenter.loadSavedWeather()
        favoritesCityesTableView.displayFavoriteCitiesTable(favorites: favoriteCityes)
    }
}

import UIKit

protocol FavoritesViewControllerProtocol: AnyObject {
    func getWeather()
    func showError(_ error: Error)
}


class FavoritesViewController: UIViewController {
    var presenter: FavoritesViewPresenterProtocol!
    var favoriteCityes: [FavoriteCity] = []
    
    lazy var favoritesCityesTableView: FavotitesTableView = {
        let view = FavotitesTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func setupNotifications() {
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleFavoritesChange),
             name: .favoritesDidChange,
             object: nil
         )
     }
    
    @objc private func handleFavoritesChange(){
        DispatchQueue.main.async { [weak self] in
                   self?.getWeather()
               }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(favoritesCityesTableView)
        getWeather()
        setupNotifications()

        NSLayoutConstraint.activate([
            favoritesCityesTableView.topAnchor.constraint(equalTo: view.topAnchor),
            favoritesCityesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            favoritesCityesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            favoritesCityesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension FavoritesViewController: FavoritesViewControllerProtocol {
    func getWeather() {
        favoriteCityes = presenter.loadSavedWeather()
        favoritesCityesTableView.displayFavoriteCitiesTable(favorites: favoriteCityes)
        
        if let city = favoriteCityes.first {
            print("City name: \(city.cityName)")
                print("Latitude: \(city.latitude)")
                print("Forecasts count: \(city.forecastArray.count)")
            print("\(city.forecastArray[0].temperature)")
            } else {
                print("No favorites")
            }
    }
}

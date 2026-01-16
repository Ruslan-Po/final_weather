import UIKit

protocol FavoritesViewControllerProtocol: AnyObject {
    func getWeather()
    func showError(_ error: Error)
}


class FavoritesViewController: UIViewController {
    var presenter: FavoritesViewPresenterProtocol!
    var favoritesCityes: [FavoriteCity] = []
    
    lazy var favoritesCityesTableView: FavotitesTableView = {
        let view = FavotitesTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        view.addSubview(favoritesCityesTableView)
        getWeather()
        
        
        NSLayoutConstraint.activate([
            favoritesCityesTableView.topAnchor.constraint(equalTo: view.topAnchor),
            favoritesCityesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            favoritesCityesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            favoritesCityesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

extension FavoritesViewController: FavoritesViewControllerProtocol {
    func getWeather() {
        favoritesCityes = presenter.loadSavedWeather()
        favoritesCityesTableView.displayFavoriteCitiesTable(favorites: favoritesCityes)
        
        if let city = favoritesCityes.first {
            print("City name: \(city.cityName)")
                print("Latitude: \(city.latitude)")
                print("Forecasts count: \(city.forecastArray.count)")
            print("\(city.forecastArray[0].temperature)")
            } else {
                print("No favorites")
            }
    }
}

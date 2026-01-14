import UIKit

protocol FavoritesViewControllerProtocol: AnyObject {
    func getWeather()
    func showError(_ error: Error)
}


class FavoritesViewController: UIViewController {
    var presenter: FavoritesViewPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeather()
    }
}

extension FavoritesViewController: FavoritesViewControllerProtocol {
    func getWeather() {
        presenter.loadSavedWeather()
    }
}

import UIKit

class FavoritesAssembler {
    static func makeFavoritesViewController(container: AppContainer) -> UIViewController {
        let view = FavoritesViewController()
        
        let presenter = FavoritesViewPresenter(view: view,
                                               dataCoreManager: container.favoritesStorage,
                                               repository: container.weatherRepository,
                                               locatonService: container.locationService)
        view.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
}

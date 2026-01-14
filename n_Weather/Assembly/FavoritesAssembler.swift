import UIKit

class FavoritesAssembler {
    static func maskeFavoritesViewController(container: AppContainer) -> UIViewController {
        let view = FavoritesViewController()
        
        let presenter = FavoritesViewPresenter(view: view,
                                               dataCoreManager: container.favoritesStorage)
        view.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
}

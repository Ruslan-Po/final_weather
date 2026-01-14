import UIKit

final class MainAssembler {
    static func createMainViewController(container: AppContainer) -> UIViewController {
        let view = MainViewController()

        let presenter = MainViewPresenter(
            view: view,
            locationService: container.locationService,
            repository: container.weatherRepository,
            citySearchService: container.citySearchService,
            locationStorage: container.storage,
            favoritesStorage: container.favoritesStorage
        )
        view.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: view)
        
        return navigationController
    }
}



import UIKit

final class MainAssembler {
    static func createMainViewController(container: AppContainer) -> UIViewController {
        let view = MainViewController()

        let presenter = MainViewPresenter(
            view: view,
            locationService: container.locationService,
            client: container.client,
            citySearchService: container.citySearchService,
            locationStorage: container.storage
        )
        view.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: view)
        
        return navigationController
    }
}

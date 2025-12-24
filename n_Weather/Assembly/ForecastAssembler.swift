import UIKit

final class ForecastAssembler {
    static func createForecastViewController(container: AppContainer) -> UIViewController {
        let view = ForecastViewController()

        let presenter = ForecastViewPresenter(
            view: view,
            client: container.client,
            locationStorage: container.storage
        )
        view.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: view)
        
        return navigationController
    }
}

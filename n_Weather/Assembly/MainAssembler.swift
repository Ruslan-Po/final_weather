import UIKit

final class MainAssembler {
    static func createMainViewController(container: AppContainer) -> UIViewController {
        let view = MainViewController()

        let presenter = MainViewPresenter(
            view: view,
            locationService: container.locationService,
            client: container.client,
            locationStorage: container.storage
        )
        view.presenter = presenter
        return view
    }
}

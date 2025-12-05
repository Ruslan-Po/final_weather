import UIKit

final class MainAssembler {
    static func createMainViewController(container: AppContainer) -> UIViewController {
        let view = MainViewController()

        let router = Router(makeForecastViewController: {
              ForecastAssembler.createForecastViewController(container: container)
          })

        let presenter = MainViewPresenter(
            view: view,
            locationService: container.locationService,
            client: container.client,
            locationStorage: container.storage
        )
        view.presenter = presenter
        view.router = router
        router.view = view
        return view
    }
}

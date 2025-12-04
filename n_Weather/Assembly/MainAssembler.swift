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

final class ForecastAssembler {
    static func createForecastViewController(container: AppContainer) -> UIViewController {
        let view = ForecastViewController()

        let presenter = ForecastViewPresenter(
            view: view,
            client: container.client,
            locationStorage: container.storage
        )
        view.presenter = presenter
        return view
    }
}

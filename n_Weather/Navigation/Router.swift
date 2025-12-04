import UIKit

protocol RouterProtocol {
    func showForecastScreen()
}

final class Router: RouterProtocol {
    weak var view: UIViewController?
    private let makeForecastViewController: () -> UIViewController

    init(makeForecastViewController: @escaping () -> UIViewController) {
        self.makeForecastViewController = makeForecastViewController
    }

    func showForecastScreen() {
        let forecastVC = makeForecastViewController()
        view?.navigationController?.pushViewController(forecastVC, animated: true)
    }
}

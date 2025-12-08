import UIKit

protocol ForecastViewControllerProtocol: AnyObject {
    func getForecast(_ forecast: [Forecast])
    func displayError(_ error: Error)
}

class ForecastViewController: UIViewController {
    var presenter: ForecastViewPresenterProtocol!
    var router: RouterProtocol?
    var tableViewTitle: String?

    lazy var forecastTableView: ForecastTableView = {
        let view = ForecastTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        view.addSubview(forecastTableView)
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        tableViewTitle = presenter.getSavedCityName() ?? "Forecast"
        presenter?.fetchUsingSavedLocation()

        NSLayoutConstraint.activate([
            forecastTableView.topAnchor.constraint(equalTo: view.topAnchor),
            forecastTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            forecastTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            forecastTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
}

extension ForecastViewController: ForecastViewControllerProtocol {
    func getForecast(_ forecast: [Forecast]) {
        forecastTableView.displayTable(forecasts: forecast)
        forecastTableView.tableTitle = tableViewTitle
    }

    func displayError(_ error: any Error) {
       showError(error)
    }
}

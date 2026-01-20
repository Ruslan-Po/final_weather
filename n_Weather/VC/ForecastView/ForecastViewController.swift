import UIKit

protocol ForecastViewControllerProtocol: AnyObject {
    func getForecast(_ forecast: [Forecast])
    func displayError(_ error: Error)
}

class ForecastViewController: UIViewController {
    var presenter: ForecastViewPresenterProtocol!
    var tableViewTitle: String?

    lazy var forecastTableView: ForecastTableView = {
        let view = ForecastTableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc private func updateForecast(_ notification: Notification) {
        presenter?.fetchUsingSavedLocation()
        tableViewTitle = presenter.getSavedCityName() ?? "Forecast"
    }

    override func viewDidLoad() {
        view.addSubview(forecastTableView)
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        subscribeToNotifications()

        NSLayoutConstraint.activate([
            forecastTableView.topAnchor.constraint(equalTo: view.topAnchor),
            forecastTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            forecastTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            forecastTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableViewTitle = presenter.getSavedCityName() ?? "Forecast"
        presenter?.fetchUsingSavedLocation()
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateForecast),
            name: .locationDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

import UIKit

class ForecastTableView: UIView {

    private var forecastData: [Forecast] = []
    var tableTitle: String?

    lazy var forecastTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = 120
        tableView.register(ForecastTableViewCell.self, forCellReuseIdentifier: CellIdentifiers.forecastCell)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(forecastTableView)
        NSLayoutConstraint.activate([
            forecastTableView.topAnchor.constraint(equalTo: topAnchor),
            forecastTableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            forecastTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            forecastTableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    public func displayTable(forecasts: [Forecast]) {
        self.forecastData = forecasts
        self.forecastTableView.reloadData()
    }
}

extension ForecastTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        forecastData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.forecastCell,
                                          for: indexPath) as? ForecastTableViewCell else {return UITableViewCell()}

        let item = forecastData[indexPath.row]
        cell.cellConfig(item: item)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.text = tableTitle
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        label.textColor = AppColors.secondary
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Layout.smallPadding),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: Layout.extraSmallPadding),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Layout.smallPadding)
        ])
            return headerView
        }

        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return UITableView.automaticDimension
        }
}

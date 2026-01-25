import UIKit

class FavoriteTableView: UIView {
    
    var onDaySelected: ((CachedWeather) -> Void)?
    var onCityDeleted: ((String) -> Void)?
    weak var cellDelegate: FavoritesTableViewCellDelegate?
    
    private var favoriteCities: [FavoriteCity] = []
    
    private let favoriteCityTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        addSubview(favoriteCityTableView)
        favoriteCityTableView.dataSource = self
        favoriteCityTableView.delegate = self
        favoriteCityTableView.register(FavoritesTableViewCell.self, forCellReuseIdentifier: CellIdentifiers.favoriteCell)
        
        NSLayoutConstraint.activate([
            favoriteCityTableView.topAnchor.constraint(equalTo: topAnchor),
            favoriteCityTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            favoriteCityTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            favoriteCityTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func displayFavoriteCitiesTable(favorite: [FavoriteCity]) {
        self.favoriteCities = favorite
        favoriteCityTableView.reloadData()
    }
    
    func showLoadingStateForAllCells() {
        for case let cell as FavoritesTableViewCell in favoriteCityTableView.visibleCells {
            cell.showLoadingState()
        }
    }
    

    func updateNotificationState(for cityName: String, enabled: Bool) {
        if let index = favoriteCities.firstIndex(where: { $0.cityName == cityName }) {
            let indexPath = IndexPath(row: index, section: 0)
            
            if let cell = favoriteCityTableView.cellForRow(at: indexPath) as? FavoritesTableViewCell {
                cell.updateNotificationState(enabled: enabled)
            }
        }
    }
}


extension FavoriteTableView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellIdentifiers.favoriteCell,
            for: indexPath
        ) as! FavoritesTableViewCell
        
        let city = favoriteCities[indexPath.row]
        cell.favoriteCellConfig(item: city)
        cell.delegate = cellDelegate
        
        cell.onDaySelected = { [weak self] cachedWeather in
            self?.onDaySelected?(cachedWeather)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cityName = favoriteCities[indexPath.row].cityName
            onCityDeleted?(cityName)
        }
    }
}

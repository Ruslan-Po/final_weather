import UIKit

class FavotiteTableView: UIView {
    var favoriteCities: [FavoriteCity] = []
    var tableTitle: String?
    var onDaySelected: ((CachedWeather) -> Void)?
    var onCityDeleted: ((String) -> Void)?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 200
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoritesTableViewCell.self, forCellReuseIdentifier: CellIdentifiers.favoriteCell)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    public func displayFavoriteCitiesTable(favorite: [FavoriteCity]) {
        self.favoriteCities = favorite
        tableView.reloadData()
    }
    
    func showLoadingStateForAllCells() {
        tableView.visibleCells.forEach { cell in
            if let favoriteCell = cell as? FavoritesTableViewCell {
                favoriteCell.showLoadingState()
            }
        }
    }
}

extension FavotiteTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellIdentifiers.favoriteCell,
            for: indexPath
        ) as? FavoritesTableViewCell else {
            return UITableViewCell()
        }

        let item = favoriteCities[indexPath.row]
        cell.favoriteCellConfig(item: item)
        
        cell.onDaySelected = { [weak self] cachedWeather in
                   self?.onDaySelected?(cachedWeather)
               }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cityToDelete = favoriteCities[indexPath.row]
            favoriteCities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            onCityDeleted?(cityToDelete.cityName)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}

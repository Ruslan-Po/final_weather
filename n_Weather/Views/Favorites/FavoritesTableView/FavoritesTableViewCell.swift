import UIKit

protocol FavoritesTableViewCellDelegate: AnyObject {
    func favoritesCell(_ cell: FavoritesTableViewCell, didTapNotificationForCity cityName: String)
    func favoritesCell(_ cell: FavoritesTableViewCell, didRequestDisableNotificationForCity cityName: String)
}

class FavoritesTableViewCell: UITableViewCell {
    var onDaySelected: ((CachedWeather) -> Void)?
    weak var delegate: FavoritesTableViewCellDelegate?
    
    private var currentCityName: String?
    private var hasNotificationsEnabled: Bool = false
    
    private let bgView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.primary
        view.layer.cornerRadius = Layout.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var pushImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bell.square")
        imageView.tintColor = AppColors.tint
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePushNotifications))
        imageView.addGestureRecognizer(tap)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    @objc func togglePushNotifications() {
        pushImageView.animateTap()
        guard let cityName = currentCityName else {
            return
        }
        if hasNotificationsEnabled {
               delegate?.favoritesCell(self, didRequestDisableNotificationForCity: cityName)
           } else {
               delegate?.favoritesCell(self, didTapNotificationForCity: cityName)
           }
    }
    
    func updateNotificationState(enabled: Bool) {
        hasNotificationsEnabled = enabled
        let imageName = enabled ? "bell.square.fill" : "bell.square"
        pushImageView.image = UIImage(systemName: imageName)
    }
    
    
    private let lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textAlignment = .left
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoritesCollectionView: FavoritesCollectionView = {
        let view = FavoritesCollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(bgView)
        bgView.addSubview(cityNameLabel)
        bgView.addSubview(tempLabel)
        bgView.addSubview(favoritesCollectionView)
        bgView.addSubview(lastUpdatedLabel)
        bgView.addSubview(pushImageView)
        
        favoritesCollectionView.onDaySelected = { [weak self] cachedWeather in
            self?.onDaySelected?(cachedWeather)
        }
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.extraSmallPadding),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.extraSmallPadding),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.smallPadding),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.smallPadding),

            lastUpdatedLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: Layout.smallPadding),
            lastUpdatedLabel.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),

            cityNameLabel.topAnchor.constraint(equalTo: lastUpdatedLabel.bottomAnchor, constant: Layout.extraSmallPadding),
            cityNameLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: Layout.smallPadding),

            tempLabel.centerYAnchor.constraint(equalTo: cityNameLabel.centerYAnchor),
            tempLabel.trailingAnchor.constraint(equalTo: pushImageView.leadingAnchor, constant: -Layout.extraSmallPadding),

            pushImageView.centerYAnchor.constraint(equalTo: cityNameLabel.centerYAnchor),
            pushImageView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -Layout.smallPadding),
            pushImageView.widthAnchor.constraint(equalToConstant: Layout.constantSmallSize),
            pushImageView.heightAnchor.constraint(equalToConstant: Layout.constantSmallSize),

            favoritesCollectionView.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: Layout.extraSmallPadding),
            favoritesCollectionView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: Layout.smallPadding),
            favoritesCollectionView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -Layout.smallPadding),
            favoritesCollectionView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -Layout.extraSmallPadding),
            favoritesCollectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func showLoadingState() {
        lastUpdatedLabel.text = "Updating..."
    }
    
    func filterCachedWeather(forecasts: [CachedWeather]) -> [CachedWeather] {
        var addedDays: Set<Date> = []
        var filteredList: [CachedWeather] = []
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        
        for item in forecasts.dropFirst() {
            let date = Date(timeIntervalSince1970: TimeInterval(item.dateTime))
            let dayStart = calendar.startOfDay(for: date)
            if dayStart != todayStart && addedDays.insert(dayStart).inserted {
                filteredList.append(item)
            }
        }
        return filteredList.reversed()
    }
    
    func favoriteCellConfig(item: FavoriteCity) {
        currentCityName = item.cityName
        cityNameLabel.text = item.cityName
        if let cachedAt = item.cachedAt {
            lastUpdatedLabel.text = "Updated: \(DateTimeHelper.updateDateFormater(from: cachedAt))"
        } else {
            lastUpdatedLabel.text = nil
        }
        
        if let current = item.currentWeather {
            tempLabel.text = String(format: "%.0f°", current.temperature)
        }
        
        let filteredForecasts = filterCachedWeather(forecasts: item.forecastArray)
        favoritesCollectionView.configure(with: filteredForecasts)
        hasNotificationsEnabled = false
        updateNotificationState(enabled: false)
    }
}

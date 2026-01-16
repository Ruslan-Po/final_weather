import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
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
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.extraSmallPadding),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.extraSmallPadding),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.smallPadding),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.smallPadding),
            
            cityNameLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: Layout.smallPadding),
            cityNameLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: Layout.smallPadding),
            
            tempLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: Layout.smallPadding),
            tempLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -Layout.smallPadding),
            
            favoritesCollectionView.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: Layout.smallPadding),
            favoritesCollectionView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: Layout.smallPadding),
            favoritesCollectionView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -Layout.smallPadding),
            favoritesCollectionView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -Layout.smallPadding),
            favoritesCollectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func favoriteCellConfig(item: FavoriteCity) {
        cityNameLabel.text = item.cityName
        
        if let current = item.currentWeather {
            tempLabel.text = String(format: "%.0f°", current.temperature)
        }
        
        let forecasts = Array(item.forecastArray.prefix(8))
        favoritesCollectionView.configure(with: forecasts)
    }
}

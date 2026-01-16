import UIKit

class FavoritesCollectionView: UIView {
    
    private var favoritesDays: [CachedWeather] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 120)
        layout.minimumInteritemSpacing = 15
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(FavoritesDayCollectionCell.self, forCellWithReuseIdentifier: CellIdentifiers.favoriteCollectionViewCell)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(with favoritesDays: [CachedWeather]) {
        self.favoritesDays = favoritesDays
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension FavoritesCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoritesDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellIdentifiers.favoriteCollectionViewCell,
            for: indexPath
        ) as? FavoritesDayCollectionCell else {
            return UICollectionViewCell()
        }
        
        let forecast = favoritesDays[indexPath.item]
        let date = DateTimeHelper.formatDate(from: Int(forecast.datetime))
        let temp = String(format: "%.0f°", forecast.temperature)
        let weatherCode = Int(forecast.weatherId)
        
        cell.configure(date: date, temperature: temp, weatherCode: weatherCode)
        return cell
    }
}

import UIKit


class ForecastTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier reuseUdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseUdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    private func setupUI(){
        contentView.addSubview(bgView)
        bgView.addSubview(dateLabel)
        bgView.addSubview(temperatureLabel)
        bgView.addSubview(descriptionLabel)
        
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            dateLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10),
            
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 10),
            descriptionLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10),
            
            temperatureLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -20)
        ])
    }

    public func cellConfig(item: Forecast){
        let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
        dateLabel.text = DateTimeHelper.formatDate(from: date)
        descriptionLabel.text = item.weather[0].description.capitalized
        let temp = item.main.feelsLike
        temperatureLabel.text =  "\(String(format: "%.1f", temp)) °C"
    }
}

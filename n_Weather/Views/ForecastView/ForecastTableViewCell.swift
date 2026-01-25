import UIKit

class ForecastTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier reuseUdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseUdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.primary
        view.layer.cornerRadius = Layout.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private func setupUI() {
        contentView.addSubview(bgView)
        bgView.addSubview(dateLabel)
        bgView.addSubview(temperatureLabel)
        bgView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.extraSmallPadding),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.extraSmallPadding),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.smallPadding),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.smallPadding),

            dateLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: Layout.smallPadding),
            dateLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: Layout.smallPadding),

            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Layout.extraSmallPadding),
            descriptionLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: Layout.smallPadding),
            descriptionLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -Layout.smallPadding),

            temperatureLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -Layout.largePadding)
        ])
    }

    public func cellConfig(item: Forecast) {
        let date = Date(timeIntervalSince1970: TimeInterval(item.datetime))
        dateLabel.text = DateTimeHelper.formatDate(from: date)
        descriptionLabel.text = item.weather[0].description.capitalized
        let temp = item.main.feelsLike
        temperatureLabel.text =  "\(String(format: "%.1f", temp)) °C"
    }
}

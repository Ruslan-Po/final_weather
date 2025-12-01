import UIKit

class SunTimeView: UIView {

    init(imageName: String) {
        super.init(frame: .zero)
        imageView.image = UIImage(named: imageName)
        setupLocalUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalTo: iv.heightAnchor).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 30).isActive = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
     let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "--:--"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    func setupLocalUI() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(timeLabel)
        
        addSubview(stackView)
        let padding = CGFloat(10)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding)
        ])
    }
}

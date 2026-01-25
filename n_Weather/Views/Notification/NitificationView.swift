import UIKit

protocol NotificationSettingsViewDelegate: AnyObject {
    func notificationSettingsView(_ view: NotificationSettingsView, didScheduleWithFrequency frequency: NotificationFrequency)
    func notificationSettingsViewDidCancel(_ view: NotificationSettingsView)
}

final class NotificationSettingsView: UIView {
    
    weak var delegate: NotificationSettingsViewDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set Notification"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let oneDayLabel: UILabel = {
        let label = UILabel()
        label.text = "One Day"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let everyDayLabel: UILabel = {
        let label = UILabel()
        label.text = "Every Day"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let modeToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.minimumDate = Date()
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = AppColors.background
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(AppColors.background, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupActions()
        updatePickersVisibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(oneDayLabel)
        containerView.addSubview(modeToggle)
        containerView.addSubview(everyDayLabel)
        containerView.addSubview(datePicker)
        containerView.addSubview(timePicker)
        containerView.addSubview(confirmButton)
        containerView.addSubview(cancelButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            oneDayLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            oneDayLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            
            modeToggle.centerYAnchor.constraint(equalTo: oneDayLabel.centerYAnchor),
            modeToggle.leadingAnchor.constraint(equalTo: oneDayLabel.trailingAnchor, constant: 20),
            
            everyDayLabel.centerYAnchor.constraint(equalTo: oneDayLabel.centerYAnchor),
            everyDayLabel.leadingAnchor.constraint(equalTo: modeToggle.trailingAnchor, constant: 20),
            
            datePicker.topAnchor.constraint(equalTo: oneDayLabel.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            timePicker.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            timePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            timePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            timePicker.heightAnchor.constraint(equalToConstant: 150),
            
            confirmButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 20),
            confirmButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        modeToggle.addTarget(self, action: #selector(modeToggleChanged), for: .valueChanged)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    @objc private func modeToggleChanged() {
        updatePickersVisibility()
    }
    
    private func updatePickersVisibility() {
        let isEveryDay = modeToggle.isOn
        
        UIView.animate(withDuration: 0.3) {
            self.datePicker.alpha = isEveryDay ? 0 : 1
            self.datePicker.isUserInteractionEnabled = !isEveryDay
        }
    }
    
    @objc private func confirmTapped() {
        let frequency: NotificationFrequency
        
        if modeToggle.isOn {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: timePicker.date)
            let hour = components.hour ?? 8
            let minute = components.minute ?? 0
            frequency = .daily(hour: hour, minute: minute)
        } else {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: datePicker.date)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: timePicker.date)
            
            var combinedComponents = DateComponents()
            combinedComponents.year = dateComponents.year
            combinedComponents.month = dateComponents.month
            combinedComponents.day = dateComponents.day
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            
            if let combinedDate = calendar.date(from: combinedComponents) {
                frequency = .once(date: combinedDate)
            } else {
                return
            }
        }
        
        delegate?.notificationSettingsView(self, didScheduleWithFrequency: frequency)
    }
    
    @objc private func cancelTapped() {
        delegate?.notificationSettingsViewDidCancel(self)
    }
    
    func show(in view: UIView) {
        frame = view.bounds
        view.addSubview(self)
        
        alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
